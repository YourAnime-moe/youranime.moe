require 'csv'

module Shows
  class SeedCsv < ApplicationOperation
    attr_reader :errors
    attr_reader :remaining

    property! :io, accepts: File
    property :range, accepts: Range

    before do
      @failed_shows = []
      treat_io
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
      params = to_param(entry)
      if Title.exists?(params[:en_title]).present?
        Rails.logger.warn("#{params[:en_title]} already exists!")
        return
      end

      @remaining ||= []

      show = Show.create(params)
      failed_shows << show unless show.persisted?
    rescue => e
      remaining << {raw: entry, parsed: params}
      Rails.logger.error("Error while creating show with params #{params.to_h}: `#{e}`")
    end

    def to_param(entry)
      params = ActionController::Parameters.new(entry).permit(
        :en_title,
        :jp_title,
        :roman_title,
        :banner_url
      )
      params[:released_on] = released_on(entry)
      params[:plot] = 'anime.plot.coming_soon'
      params
    end

    def released_on(entry)
      JSON.parse(entry[:aired].gsub('\'', '"'))['from']
    rescue
      Time.now.utc
    end

    def create_episodes(show, count); end
  end  
end