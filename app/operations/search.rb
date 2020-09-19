class Search < ApplicationOperation
  property :search, accepts: String, converts: :downcase
  property :limit, accepts: Integer
  property :format, accepts: [:whole, :shows], default: :whole, converts: :to_sym

  def execute
    return empty_search_result unless search.present? && search.size > 2
    final_results = shows_results.trending.order(:show_type)
    return final_results if format == :shows

    show_types = final_results.pluck(:show_type).uniq

    show_types.map do |show_type|
      [show_type, final_results.where(show_type: show_type)]
    end
  end

  private

  def shows_results
    @shows_results ||= search_shows_by_title
      .or(search_shows_by_genre)
      #.or(search_shows_by_tags)
  end

  def search_shows_by_title
    Show.searchable.where('lower(titles.en) LIKE ?', like_search)
      .or(Show.searchable.where('lower(titles.jp) LIKE ?', like_search))
      .or(Show.searchable.where('lower(titles.roman) LIKE ?', like_search))
  end

  def search_shows_by_genre
    Show.searchable.where('lower(show_type) LIKE ?', like_search)
  end

  def search_shows_by_tags
    Show.searchable
      .joins(:tags)
      .where('lower(tags.value) LIKE ?', like_search)
  end

  def empty_search_result
    {shows: []}
  end

  def like_search
    "%#{search}%"
  end
end
