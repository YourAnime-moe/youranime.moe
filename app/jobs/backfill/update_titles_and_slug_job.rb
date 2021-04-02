# frozen_string_literal: true
module Backfill
  class UpdateTitlesAndSlugJob < ApplicationJob
    queue_as :default

    def perform(show_ids)
      title_records = ActiveRecord::Base.connection.execute(
        "select en, jp, model_id from titles where model_id in (#{show_ids.join(', ')})",
      )

      title_records.each do |record|
        show = Show.find(record['model_id'])
        titles = {
          en: record['en'],
          jp: record['jp'],
        }.compact

        show.update_attribute(:titles, titles)
        show.update_attribute(:slug, title_record.roman)
      end
    end
  end
end
