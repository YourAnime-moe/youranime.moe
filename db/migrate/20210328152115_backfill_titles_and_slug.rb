# frozen_string_literal: true
class BackfillTitlesAndSlug < ActiveRecord::Migration[6.1]
  def up
    Show.find_in_batches.each do |shows|
      Backfill::UpdateTitlesAndSlugJob.perform_later(shows.map(&:id))
    end
  end

  def down
    # ignore
  end
end
