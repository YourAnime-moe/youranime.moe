class KitsuSearch
  attr_reader :search_results, :results

  class Result
    attr_accessor \
      :titles,
      :canonical_title,
      :slug,
      :poster_image,
      :year,
      :nsfw,
      :kitsu_id

    attr_reader :similarity

    def initialize(query)
      @query = query
    end

    def show
      @show ||= fetch_show
    end

    def platforms(*args, **kwargs)
      show.platforms(*args, **kwargs)
    end

    def similar?(threshold = 0.7)
      similar_by_title? || similarity >= threshold
    end

    private

    def titles_to_compare
      titles.values.push(canonical_title).reject(&:blank?)
    end

    def similar_by_title?
      titles_to_compare.any? do |title|
        title.downcase.start_with?(@query.downcase) ||
          @query.downcase.start_with?(title.downcase)
      end
    end

    def similarity
      titles_to_compare.map do |title|
        LevenshteinDistance.perform(s1: @query, s2: title)
      end.max
    end

    def fetch_show
      Show.find_by_slug(slug) || Shows::Kitsu::Get.perform(kitsu_id: kitsu_id, force_update: true)
    end
  end

  def initialize(text, similarity_threshold: 0.8)
    @text = ensure_text_filter!(text)
    @ran = false
    @similarity_threshold = similarity_threshold
  end

  def run!
    return if ran? || @text.nil?

    @search_results = ::Kitsu::ApiRequest.perform(
      endpoint: "/anime?filter[text]=#{CGI.escape(@text)}",
      params: {
        include: 'genres,categories,mappings',
        page: { limit: 20, offset: 0 }
      },
    )

    @results = process_search_results!
  end

  def ran?
    @ran
  end

  private

  def ensure_text_filter!(text)
    query = text.strip
    return query if query.size > 2
  end

  def process_search_results!
    @search_results.dig(:data).map do |data|
      attributes = data[:attributes]

      result = Result.new(@text)
      result.titles = attributes[:titles]
      result.canonical_title = attributes[:canonicalTitle]
      result.slug = attributes[:slug]
      result.poster_image = attributes[:posterImage]
      result.year = attributes[:year]
      result.nsfw = attributes[:nsfw]
      result.kitsu_id = data[:id]

      result
    end.select do |result|
      result.similar?(@similarity_threshold)
    end
  end
end
