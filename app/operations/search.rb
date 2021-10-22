# frozen_string_literal: true
class Search < ApplicationOperation
  property :search, accepts: String, converts: :downcase
  property! :limit, accepts: Integer # Max: 20
  property :tags, accepts: Array
  property :active, accepts: [true, false], default: false
  property :format, accepts: [:whole, :shows], default: :whole, converts: :to_sym

  def execute
    return empty_search_result unless any_search_attributes?

    final_results = if (platform = Platform.find_by(name: search))
      platform.shows.order(:status)
    else
      shows_results
    end.by_tags(*Array(tags)).order(:show_type)

    final_results = final_results.active if active
    return final_results.trending if format == :shows

    show_types = final_results.pluck(:show_type).uniq

    show_types.map do |show_type|
      [show_type, final_results.where(show_type: show_type)]
    end
  end

  private

  def any_search_attributes?
    search.present? && search.size >= minimum_query_length || tags.present?
  end

  def minimum_query_length
    japanese_characters? ? 1 : 3
  end

  def japanese_characters?
    !!(search =~ /\p{Han}|\p{Katakana}|\p{Hiragana}/)
  end

  def shows_results
    @shows_results ||= search_shows_by_title
    # .or(search_shows_by_genre)
    # .or(search_shows_by_tags)
  end

  def search_shows_by_title
    Show.search(search, limit: ensure_limit)
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
    format == 'whole' ? { shows: [] } : []
  end

  def like_search
    "%#{search}%"
  end

  private

  def ensure_limit
    limit < 20 ? limit : 20
  end
end
