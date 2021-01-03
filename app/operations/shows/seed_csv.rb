# frozen_string_literal: true
require 'csv'

module Shows
  class SeedCsv < ApplicationOperation
    class AlreadyExistsError < StandardError
    end

    attr_reader :errors
    attr_reader :remaining

    property! :data, accepts: Array
    property :locales, accepts: Array, default: -> { [:en, :jp] }

    before do
      Rails.logger.info("[Shows::SeedCsv] Processing #{data.size}")
      @failed_shows = []
    end

    halted do
      @errors = failed_shows.map do |show|
        { error: show.errors.full_messages, show_id: show.id }
      end
    end

    def execute
      shows_data.each do |entry|
        create_show(entry)
      end

      success = failed_shows.empty?
      halt unless success
      success
    end

    private

    attr_reader :data
    attr_reader :failed_shows

    def shows_data
      data
    end

    def create_show(entry)
      @remaining ||= []

      banner_io = try_fetching_image_tempfile(entry)
      title_params = title_params(entry)

      show = create_show!(title_params, entry, banner_io)
      if show.persisted?
        show.generate_banner_url!(force: true)
      else
        failed_shows << show
      end
    rescue AlreadyExistsError => e
      remaining << { raw: entry, parsed: entry }
      Rails.logger.error("Error while creating show with params #{entry.to_h}: `#{e}`")
    end

    def create_show!(title_params, entry, banner_io)
      # Japanese title is guarenteed to be unique# Japanese title is guarenteed to be unique
      raise AlreadyExistsError, "#{title_params[:en]} already exists" if Title.where(en: title_params[:en]).present?

      create_show_instance!(title_params, entry, banner_io)
    end

    def create_show_instance!(title_params, _entry, banner_io)
      show = Show.new(published: true)
      show.title = Title.new(title_params)
      show.description = Description.new(en: "Description for #{show.title}") # description(entry)
      show.save!
      show.banner.attach(io: banner_io, filename: "uploaded-for-show-#{show.id}") if show.persisted? && banner_io
      show
    end

    def try_fetching_image_tempfile(entry)
      Down.download(entry[:image_url])
    rescue => e
      Rails.logger.error(e)
      nil
    end

    def title_params(entry)
      parsed = parse_translatable_params(entry, :title)
      ActionController::Parameters.new(parsed).permit(*locales)
    end

    def description_params(entry)
      parsed = parse_translatable_params(entry, :description)
      ActionController::Parameters.new(parsed).permit(*locales)
    end

    def description(entry)
      Description.new(description_params(entry))
    end

    def parse_translatable_params(entry, type)
      entry.map { |k, v| [mappings_for(type)[k], v] }.to_h
    end

    def mappings_for(type)
      locales.map { |k, _v| [:"#{type}_#{k}", k] }.to_h
    end

    def released_on(entry)
      JSON.parse(entry[:aired].gsub('\'', '"'))['from']
    rescue
      Time.now.utc
    end

    def create_episodes(show, count); end
  end
end
