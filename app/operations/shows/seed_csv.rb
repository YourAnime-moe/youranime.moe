require 'csv'

module Shows
  class SeedCsv < ApplicationOperation
    attr_reader :errors
    attr_reader :remaining

    property! :io, accepts: File
    property! :banners_root, accepts: String
    property :range, accepts: Range
    property :locales, accepts: Array, default: -> { [:en, :jp, :fr] }

    before do
      @failed_shows = []
      treat_io

      # Check if the directory exists
      Dir.entries(banners_root)
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

    def treat_io
      return @data if @data

      raw_data = io.read
      csv = CSV.new(raw_data,
        headers: true,
        header_converters: :symbol,
        converters: :all
      )

      @data = csv.to_a.map { |row| row.to_hash }
    end

    def shows_data
      @shows_data ||= range ? data[range] : data
    end

    def create_show(entry)
      @remaining ||= []

      banner_io = File.open("#{banners_root}/#{entry[:filename]}")
      title_params = title_params(entry)

      show = create_show!(title_params, entry, banner_io)
      failed_shows << show if show.persisted?
    rescue => e
      remaining << { raw: entry, parsed: entry }
      Rails.logger.error("Error while creating show with params #{entry.to_h}: `#{e}`")
    end

    def create_show!(title_params, entry, banner_io)
      # Japanese title is guarenteed to be unique# Japanese title is guarenteed to be unique
      raise "#{title_params[:en]} already exists" if Title.where(jp: title_params[:jp]).present?

      create_show_instance!(title_params, entry, banner_io)
    end

    def create_show_instance!(title_params, entry, banner_io)
      show = Show.new(published: true, published_on: Time.now.utc)
      show.title = Title.new(title_params)
      show.description = description(entry)
      show.save!
      show.banner.attach(io: banner_io, filename: entry[:filename]) if show.persisted?
      show
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
      entry.map {|k, v| [mappings_for(type)[k], v]}.to_h
    end

    def mappings_for(type)
      locales.map {|k, v| [:"#{type}_#{k}", k]}.to_h
    end

    def released_on(entry)
      JSON.parse(entry[:aired].gsub('\'', '"'))['from']
    rescue
      Time.now.utc
    end

    def create_episodes(show, count); end
  end  
end