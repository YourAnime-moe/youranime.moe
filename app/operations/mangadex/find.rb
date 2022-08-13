module Mangadex
  class Find < ApplicationOperation
    property! :medium

    def execute
      cached_data = Rails.cache.read(cache_key)
      return cached_data if cached_data.present?

      manga = find_matching_mangadex_manga
      Rails.cache.write(cache_key, manga)

      manga
    end

    private

    def record
      return medium if medium.respond_to?(:id)
      return @record if @record.present?

      id = medium.to_s.to_i
      raise ArgumentError, "#{medium} must either respond to `id` or be a positive integer" if id.zero?

      operation = Anilist::Search.new(variables: { id: id })
      operation.call

      if operation.halted? || operation.result.errored?
        raise ArgumentError, "No Anilist media found with `id`=#{id}"
      end

      @record = operation.result.data.page.media.first
    end

    def cache_key
      "anilist:medium:#{record.id}"
    end

    def find_matching_mangadex_manga
      media = [record].concat(record.relations.nodes)
      manga_medium = media.find(&method(:manga?))

      mangadex_manga_for_manga(manga_medium)
    end

    def mangadex_manga_for_manga(medium)
      return unless manga?(medium)

      medium.title.to_h.values.each do |title|
        result = Mangadex::Manga.list(
          title: medium.title.native,
          order: {
            relevance: "asc",
            followedCount: "desc",
          }
        )
        return result.data if result.result == "ok" && result.data.any?
      end

      nil
    end

    def manga?(medium)
      medium.present? && medium.type == "MANGA" && medium.format == "MANGA"
    end
  end
end
