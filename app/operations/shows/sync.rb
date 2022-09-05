# frozen_string_literal: true
module Shows
  class Sync < ApplicationOperation
    property! :sync_type, accepts: [:airing, :episodes, :crawl, :show, :shows]
    property! :requested_by, accepts: Users::Admin
    property :show, accepts: Show
    property :by_season, accepts: [:fall, :winter, :spring, :summer]
    property :by_year, accepts: Integer

    REQUEST_URL_BASE = 'https://kitsu.io/api/edge/anime'

    def execute
      return sync_airing if sync_type == :airing
      return sync_episodes if sync_type == :episodes
      return crawl_shows if sync_type == :crawl
      return sync_show if sync_type == :show
      return sync_shows if sync_type == :shows
    end

    private

    attr_accessor :current_page

    def sync_shows
      @current_page = 0
      create_shows_then_next_page({ season: by_season, year: by_year })
    end

    def sync_airing
      @current_page = 0
      [current_season, next_season].each do |season|
        create_shows_then_next_page(season)

        # For each season, reset the page
        @current_page = 0
      end
    end

    def sync_episodes
      raise '`show` params is mandatory with sync_type: :episodes' unless show.present?
      return if show.reference_id.blank?

      Rails.logger.info("[Shows::Sync] #{request_episodes_url(show)}")
      override_episodes_for(show)
    end

    def sync_show
      raise '`show` params is mandatory with sync_type: :show' unless show.present?
      return unless show.synchable?

      response = RestClient.get(request_show_url(show))
      return unless response.code < 300 && response.code >= 200

      data = JSON.parse(response.body).deep_symbolize_keys
      return if data[:data].blank?

      create_or_update_show_for(data[:data], nil, show_obj: show)
    end

    def crawl_shows
      raise 'Crawling is not allowed.' unless Rails.configuration.allows_crawling

      @current_url = "https://kitsu.io/api/edge/anime?page%5Blimit%5D=20&page%5Boffset%5D=0"
      @has_next = true

      while @has_next
        begin
          response = RestClient.get(@current_url)
          return unless response.code < 300 && response.code >= 200

          data = JSON.parse(response.body).deep_symbolize_keys
          if data[:data].blank?
            return
          end

          data[:data].each do |show_data|
            create_or_update_show_for(show_data, nil)
          end

          @has_next = data[:links][:last] != @current_url
          @current_url = data[:links][:next]
        rescue Down::Error => e
          # ignore
          Rails.logger.error(e)
          puts e.backtrace
        end
      end
    end

    def create_shows_then_next_page(season)
      Rails.logger.info("[Shows::Sync] #{request_airing_url(season)}")
      there_is_data = true
      created_shows = []

      while there_is_data
        response = RestClient.get(request_airing_url(season))
        return unless response.code < 300 && response.code >= 200

        data = JSON.parse(response.body).deep_symbolize_keys
        if data[:data].blank?
          there_is_data = false
        end

        data[:data].each do |show_data|
          created_shows << create_or_update_show_for(show_data, season[:status])
        end

        @current_page += 1
      end

      created_shows
    end

    def create_or_update_show_for(data, airing_status, show_obj: nil)
      fetched_attrs = data[:attributes]
      synched_show = show_obj.present? ? show_obj : find_show_from_attributes(fetched_attrs)

      if synched_show.persisted?
        if synched_show.description_record.present?
          synched_show.description_record.update(en: fetched_attrs[:synopsis] || fetched_attrs[:description])
        else
          synched_show.description = Description.new(
            en: 'No description exists for this show yet.',
            fr: 'Aucune description n\'existe pour ce show pour le moment',
            jp: 'このショーには概要やあらすじがまだありません。',
          )
        end
      end

      synched_show.popularity = fetched_attrs[:popularityRank]
      synched_show.show_type = data[:type]
      synched_show.show_category = fetched_attrs[:subtype]
      synched_show.age_rating = fetched_attrs[:ageRating]
      synched_show.age_rating_guide = fetched_attrs[:ageRatingGuid]
      synched_show.status = fetched_attrs[:status]
      synched_show.starts_on = fetched_attrs[:startDate]
      synched_show.ended_on = fetched_attrs[:endDate]
      synched_show.nsfw = fetched_attrs[:nsfw].to_s == 'true'

      synched_show.airing_status = airing_status_for(synched_show, default: airing_status)
      synched_show.youtube_trailer_id = fetched_attrs[:youtubeVideoId]

      synched_show.synched_at = Time.now.utc
      synched_show.synched_by = requested_by.id
      synched_show.reference_source = :kitsu
      synched_show.reference_id = data[:id]

      synched_show.published = !synched_show.persisted? || synched_show.published?
      synched_show.save!

      override_episodes_for(synched_show)

      poster_url = fetched_attrs.dig(:posterImage, :large) || fetched_attrs.dig(:posterImage, :original)
      banner_url = fetched_attrs.dig(:coverImage, :large) || fetched_attrs.dig(:coverImage, :original)

      banner_file = try_downloading(banner_url)
      if banner_file
        synched_show.banner.attach(io: banner_file, filename: "show-#{synched_show.id}-banner")
        banner_file.unlink
      end

      poster_file = try_downloading(poster_url)
      if poster_file
        synched_show.poster.attach(io: poster_file, filename: "show-#{synched_show.id}-poster")
        poster_file.unlink
      end

      synched_show.update_banner_and_poster_urls!(force: true)
      streamer_urls_for!(synched_show)

      synched_show
    end

    def find_show_from_attributes(fetched_attrs)
      found_title_record = Title.find_by(roman: fetched_attrs[:slug])
      english_title = fetched_attrs.dig(:titles, :en) ||
        fetched_attrs.dig(:titles, :en_us) ||
        fetched_attrs.dig(:titles, :en_jp) ||
        fetched_attrs[:canonicalTitle]

      japanese_title = fetched_attrs.dig(:titles, :jp) ||
        fetched_attrs.dig(:titles, :ja) ||
        fetched_attrs.dig(:titles, :ja_jp)

      description_content = fetched_attrs[:synopsis] || fetched_attrs[:description]

      if found_title_record.blank?
        Show.new.tap do |show|
          show.title = Title.new(roman: fetched_attrs[:slug], en: english_title, jp: japanese_title)
          show.description = Description.new(en: description_content)
        end
      else
        found_title_record.update(en: english_title, jp: japanese_title)
        found_title_record.record
      end
    end

    def override_episodes_for(show)
      #::Sync::Shows::ReactionCountJob.perform_later(show)
      return if show.reference_id.blank?

      response = RestClient.get(request_episodes_url(show))
      return unless response.code < 300 && response.code >= 200

      data = JSON.parse(response.body).deep_symbolize_keys
      return if data[:data].blank?

      show.update_banner_and_poster_urls!(force: true)

      # Delete and replace all episods from the first season.
      season = show.seasons.first_or_create!

      season.episodes.destroy_all
      episodes_count = data[:meta].present? ? data[:meta][:count] : 0
      show.update(
        synched_at: Time.now.utc,
        synched_by: requested_by.id,
        episodes_count: episodes_count,
      )
    end

    def streamer_urls_for!(show)
      return if show.reference_id.blank?

      response = RestClient.get(request_streamer_url(show))
      return unless response.code < 300 && response.code >= 200

      data = JSON.parse(response.body).deep_symbolize_keys
      return if data[:data].blank?

      show.urls.destroy_all
      data[:data].each do |streamer_url_data|
        attrs = streamer_url_data[:attributes]

        show.urls.create!(value: attrs[:url])
      end
    end

    def request_airing_url(season)
      filters = { season: season[:season], seasonYear: season[:year] }
      page_info = { limit: 20, offset: current_page * 20 }

      filters_as_params = as_params(filters, :filter)
      page_info_as_params = as_params(page_info, :page)

      "#{REQUEST_URL_BASE}?#{filters_as_params}&#{page_info_as_params}"
    end

    def request_show_url(show)
      "#{REQUEST_URL_BASE}/#{show.reference_id}"
    end

    def request_episodes_url(show)
      "#{REQUEST_URL_BASE}/#{show.reference_id}/relationships/episodes"
    end

    def request_streamer_url(show)
      "#{REQUEST_URL_BASE}/#{show.reference_id}/streaming-links?page[limit]=20&page[offset]=0"
    end

    def airing_status_for(show, default: 'unknown')
      return default if show.starts_on.blank?

      today_s_date = DateTime.now.utc
      if show.starts_on < today_s_date
        # it's already started
        if show.ended_on.present? && show.ended_on != show.starts_on
          # we know the ended date
          if show.ended_on < today_s_date
            # it's already over
            'complete'
          else
            # if it's not over... it's airing
            'airing'
          end
        else
          # odds it's still airing?
          # TODO: more tests
          'airing'
        end
      else
        'coming_soon'
      end
    end

    def current_season
      Config.current_season
    end

    def next_season
      Config.next_season
    end

    def as_params(array, param_type)
      array.map { |k, v| "#{param_type}[#{k}]=#{v}" }.join('&')
    end

    def try_downloading(url)
      return if url.blank?

      Down.download(url)
    rescue Down::Error
      nil
    end
  end
end
