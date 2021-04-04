# frozen_string_literal: true
class Tag < ApplicationRecord
  has_many :shows_tag_relations, inverse_of: :tag

  # This may not work with pluck!
  scope :popular, -> do
    select('count(*) AS popularity_count', 'tags.*')
      .joins(:shows_tag_relations)
      .group('tags.id')
      .having('count(*) > 0')
      .order('popularity_count desc')
  end

  # all tags in common for that list of shows
  # test (1497, 1735, 49)
  # test (222, 590, 2317)

  # select tags.* from tags
  # inner join shows_tag_relations str on str.tag_id = tags.id
  # inner join shows on str.show_id = shows.id
  # where shows.id in (222, 590, 2317)
  # group by tags.id
  # having count(tags.*) = 3;

  def self.by_shows(*shows)
    show_ids = shows.map do |show|
      next show if show.is_a?(Show)
      Show.find_by(id: show) || Show.find_by(slug: show)
    end.compact.map(&:id)

    joins(:shows_tag_relations, 'INNER JOIN "shows" on "shows"."id" = "shows_tag_relations"."show_id"')
      .where('shows.id' => show_ids)
      .group('"tags"."id"')
      .having('count("tags".*) = ?', show_ids.count)
  end
end
