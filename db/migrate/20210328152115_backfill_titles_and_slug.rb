# frozen_string_literal: true
class BackfillTitlesAndSlug < ActiveRecord::Migration[6.1]
  def change
    Show.all.each do |show|
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
