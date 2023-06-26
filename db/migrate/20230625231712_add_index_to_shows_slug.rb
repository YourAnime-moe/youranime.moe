
class AddIndexToShowsSlug < ActiveRecord::Migration[7.0]
  def change
    slugs = Show.pluck(:slug)
    dup_slugs = slugs.tally.filter { |_, count| count > 1 }.keys
    show_ids_to_delete = Show.where(slug: dup_slugs).group_by do |show|
      show.slug
    end.values.map { |shows| shows[1..] }.flatten.map do |show|
      show.id
    end

    Show.find(show_ids_to_delete).each(&:destroy)

    add_index(:shows, :slug, unique: true)
  end
end
