# frozen_string_literal: true
module Backfill
  class UpdateTitlesAndSlugJob < ApplicationJob
    queue_as :default

    def perform(show_ids)
      Show.where(id: show_ids).each do |show|
        title_record = show.title_record
        next unless title_record.present?

        titles = {
          en: title_record.en,
          jp: title_record.jp,
        }.compact

        show.update(titles: titles, slug: title_record.roman)
      end
    end
  end
end
