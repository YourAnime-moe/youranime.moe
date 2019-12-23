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

      # Japanese title is guarenteed to be unique
      if Title.where(jp: title_params[:jp]).present?
        Rails.logger.warn("#{title_params[:en]} already exists!")
        return
      end

      title = Title.new(title_params)
      description = Description.new(description_params(entry))

      show = Show.new(
        published: true,
        published_on: Time.now.utc,
      )
      show.title = title
      show.description = description
      show.save!
      if show.persisted?
        show.banner.attach(io: banner_io, filename: entry[:filename])
        p show.errors.to_a
      else
        failed_shows << show unless show.persisted?
      end
    rescue => e
      remaining << {raw: entry, parsed: entry}
      Rails.logger.error("Error while creating show with params #{entry.to_h}: `#{e}`")
    end

    def title_params(entry)
      parsed = parse_translatable_params(entry, :title)
      ActionController::Parameters.new(parsed).permit(*locales)
    end

    def description_params(entry)
      parsed = parse_translatable_params(entry, :description)
      ActionController::Parameters.new(parsed).permit(*locales)
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