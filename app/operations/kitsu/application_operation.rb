# frozen_string_literal: true
module Kitsu
  class ApplicationOperation < ::ApplicationOperation
    property :with_user, accepts: User

    protected

    def find_or_create_show!(show_options, show_source)
      show = if (show = find_show(show_options))
        show
      else
        new_show = build_show_from(show_options[:attributes])
        new_show.reference_id = show_options[:id]
        new_show.reference_source = show_source
        new_show.show_type = show_options[:type]
        new_show.save!

        new_show
      end

      try_adding_images(show, show_options[:attributes])
      show
    end

    # Accepts: results.data.attributes
    def build_show_from(results)
      new_show = Show.new(show_options(results))

      new_show.title = Title.new(show_title_options(results))
      new_show.description = Description.new({ en: results[:synopsis] || results[:description] })

      # new_show.build_cover(results[:coverImage].except(:meta)) if results[:coverImage]
      # new_show.build_poster(results[:posterImage].except(:meta)) if results[:posterImage]
      # new_show.tags = show_tags

      new_show
    end

    def streaming_platforms_from_anilist!(search_results, show)
      anilist_id = anilist_id_from(search_results)
      return unless anilist_id.present?

      show_urls = Shows::Anilist::Streamers.perform(
        anilist_id: anilist_id,
        show: show,
        persist: true,
      )
      show.urls = show_urls if show_urls.present?

      show_urls
    rescue ActiveRecord::NotNullViolation
      show.urls.delete_all

      show.urls = show_urls
    end

    def anilist_id_from(search_results)
      return unless @included.is_a?(Array) && @included.any?

      search_results.dig(:relationships, :mappings, :data).map do |data|
        next unless data[:type] == 'mappings'

        @included.filter do |included_data|
          included_data[:type] == 'mappings' &&
            data[:id] == included_data[:id] &&
            included_data.dig(:attributes, :externalSite) =~ /anilist/
        end.map do |included_data|
          included_data.dig(:attributes, :externalId)
        end
      end.compact.flatten.first
    end

    def show_options(results)
      nsfw = if results[:nsfw].nil?
        allows_nsfw?
      else
        results[:nsfw]
      end

      {
        episodes_count: results[:episodeCount] || 0,
        starts_on: results[:startDate],
        ended_on: results[:endDate],
        age_rating: results[:ageRating],
        age_rating_guide: results[:ageRatingGuide],
        status: results[:status],
        show_category: results[:subtype] || results[:showType],
        popularity: results[:popularityRank],
        nsfw: nsfw,
        published: !nsfw,
        synched_at: Time.now.utc,
      }
    end

    def show_title_options(results)
      titles = results[:titles]

      {
        en: any_of(titles, :en),
        jp: any_of(titles, :jp) || any_of(titles, :ja),
        roman: results[:slug],
        # canonical: results[:canonicalTitle],
        # abbreviated: '', # results[:abbreviatedTitles]&.join(', '),
      }
    end

    def try_adding_images(show, show_options, force: false)
      poster_missing = !show.poster.attached?
      banner_missing = !show.banner.attached?

      if force || poster_missing
        try_image(:poster, show_options) do |file|
          show.poster.attach(io: file, filename: "show-#{show.id}-poster")
        end
      end

      if force || banner_missing
        try_image(:cover, show_options) do |file|
          show.banner.attach(io: file, filename: "show-#{show.id}-banner")
        end
      end

      show
    end

    def sync_show_images!(show, force: false)
      show.generate_banner_url!(force: true) if force || show.banner_url == Show::DEFAULT_BANNER_URL
      show.generate_poster_url!(force: true) if force || show.poster_url == Show::DEFAULT_POSTER_URL
    end

    def try_image(type, options)
      key = :"#{type}Image"
      image_url = options.dig(key, :original) ||
        options.dig(key, :large) ||
        options.dig(key, :medium) ||
        options.dig(key, :small) ||
        options.dig(key, :tiny)

      return unless image_url

      image_file = Down.download(image_url)
      yield image_file

      image_file.unlink
    rescue Down::Error
      nil
    end

    def show_tags
      show_tags_options&.map do |tag_option|
        Tag.find_or_create_by(ref_id: tag_option[:ref_id]) do |tag|
          tag.assign_attributes(tag_option)
        end
      end || []
    end

    def show_tags_options
      return unless @included.present?

      @included.filter do |result|
        result[:type] == 'categories'
      end.map do |result|
        {
          value: result.dig(:attributes, :title),
          ref_url: result.dig(:links, :self),
          ref_id: result[:id],
          tag_type: search_results[:type],
        }
      end
    end

    def refresh_show_urls!(show)
      show.urls.refresh_all!
    end

    def allows_nsfw?
      with_user.present? && with_user.allows_nsfw?
    end

    private

    def find_show(show_options)
      ::Shows::Kitsu::Get.perform(
        kitsu_id: show_options[:id],
        force_update: try(:update_if_found).present?,
      )
    end

    def any_of(titles, starting_with)
      titles.each do |key, value|
        next if value.blank?
        return value if key.start_with?(starting_with.to_s)
      end
      nil
    end
  end
end
