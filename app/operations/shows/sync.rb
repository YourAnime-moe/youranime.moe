module Shows
  class Sync < ApplicationOperation
    property! :sync_type, accepts: [:airing]

    REQUEST_URL_BASE = 'https://kitsu.io/api/edge/anime'

    WINTER_SEASON = :winter
    SPRING_SEASON = :spring
    SUMMER_SEASON = :summer
    FALL_SEASON = :fall

    SEASON_CODES = {
      WINTER_SEASON => 0,
      SPRING_SEASON => 1,
      SUMMER_SEASON => 2,
      FALL_SEASON => 3,
    }.freeze

    def execute
      @current_page = 1
      Rails.logger.info("[Shows::Sync] #{request_url}")

      response = RestClient.get(request_url)
      halt unless response.code < 300 && response.code >= 200

      data = JSON.parse(response.body).deep_symbolize_keys
      return if data[:data].blank?

      created_shows = []
      data[:data].each do |show_data|
        created_shows << create_or_update_show_for(show_data)
      end

      created_shows
    end

    private
    attr_accessor :current_page

    def create_shows_then_next_page
      there_is_data = true
      created_shows = []

      while there_is_data
        response = RestClient.get(request_url)
        return unless response.code < 300 && response.code >= 200

        data = JSON.parse(response.body).deep_symbolize_keys
        if data[:data].blank?
          there_is_data = false
        end

        data[:data].each do |show_data|
          created_shows << create_or_update_show_for(show_data)
        end

        current_page += 1
      end
    end

    def create_or_update_show_for(data)
      fetched_attrs = data[:attributes]
      found_title_record = Title.find_by(roman: fetched_attrs[:slug])

      english_title = fetched_attrs.dig(:titles, :en) || fetched_attrs.dig(:titles, :en_us) || fetched_attrs.dig(:titles, :en_jp) || fetched_attrs[:canonicalTitle]
      japanese_title = fetched_attrs.dig(:titles, :jp) || fetched_attrs.dig(:titles, :ja) || fetched_attrs.dig(:titles, :ja_jp)
      description_content = fetched_attrs[:synopsis] || fetched_attrs[:description]

      synched_show = if found_title_record.blank?
        Show.new(show_type: data[:type]).tap do |show|
          show.title = Title.new(roman: fetched_attrs[:slug], en: english_title, jp: japanese_title)
          show.description = Description.new(en: description_content)
        end
      else
        found_title_record.update(en: english_title, jp: japanese_title)
        found_title_record.record
      end

      if synched_show.persisted?
        synched_show.description_record.update(en: description_content)
      end

      synched_show.save!

      synched_show.seasons.destroy_all
      fetched_attrs[:episodeCount].to_i.times do |index|
        season = synched_show.seasons.first_or_create!
        season.episodes.first_or_create!(
          number: (index + 1),
          title: "Episode #{index + 1}",
          duration: fetched_attrs[:episodeLength],
          published: false,
        )
      end

      banner_file = Down.download(fetched_attrs.dig(:posterImage, :large) || fetched_attrs.dig(:posterImage, :original))
      synched_show.banner.attach(io: banner_file, filename: "show-#{synched_show.id}")
      synched_show.generate_banner_url!(force: true)
      banner_file.unlink

      synched_show
    end

    def request_url
      filters = { season: current_season[:season], seasonYear: current_season[:year] }
      page_info = { limit: 20, offset: current_page * 20 }

      filters_as_params = as_params(filters, :filter)
      page_info_as_params = as_params(page_info, :page)

      "#{REQUEST_URL_BASE}?#{filters_as_params}&#{page_info_as_params}"
    end

    def current_season
      current_date = Time.now.utc
      {
        year: current_date.year,
        season: season_name_from(current_date),
      }
    end

    def next_season
      current_date = Time.now.utc
      current_season_code = season_code_from(current_date)

      next_season_code = (current_season_code + 1) % SEASON_CODES.count
      next_season_year = current_season_code < next_season_code ? current_date.year : current_date.year + 1

      {
        year: next_season_year,
        season: season_name_for(next_season_code),
      }
    end

    def season_code_from(date)
      case date.month
      when 1..3
        SEASON_CODES[WINTER_SEASON]
      when 4..6
        SEASON_CODES[SPRING_SEASON]
      when 7..9
        SEASON_CODES[SUMMER_SEASON]
      when 10..12
        SEASON_CODES[FALL_SEASON]
      end
    end

    def season_name_from(date)
      season_name_for(season_code_from(date))
    end

    def season_name_for(code)
      SEASON_CODES.key(code)
    end

    def as_params(array, param_type)
      array.map{ |k, v| "#{param_type}[#{k}]=#{v}" }.join('&')
    end
  end
end
