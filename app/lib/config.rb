# frozen_string_literal: true

module Config
  class Error < StandardError
  end

  mattr_accessor :videojs
  @@videojs = nil

  WINTER_SEASON = :winter
  SPRING_SEASON = :spring
  SUMMER_SEASON = :summer
  FALL_SEASON = :fall

  SEASON_CODES = {
    WINTER_SEASON => 0,
    SPRING_SEASON => 1,
    SUMMER_SEASON => 2,
    FALL_SEASON => 3,
  }.freeze

  class << self
    def slack_client
      return @slack_client unless @slack_client.nil?

      @slack_client = Slack::Web::Client.new
      begin
        @slack_client.auth_test
      rescue Slack::Web::Api::Errors::SlackError
        warn('Could not auth to Slack. Are you connected?')
        @slack_client = nil
      end
    end

    def demo?
      ENV['DEMO'].to_s.downcase.strip == 'true'
    end

    def google_client_id
      ENV['GOOGLE_OAUTH_CLIENT_ID']
    end

    def misete_client_id
      ENV['MISETE_OAUTH_CLIENT_ID']
    end

    def google_oauth_enabled?
      ENV['DISABLE_GOOGLE_LOGIN'].blank?
    end

    def oauth_enabled?
      (google_client_id.present? && google_oauth_enabled?) || misete_client_id.present?
    end

    def uses_disk_storage?
      Rails.application.config.active_storage.service == :local
    end

    def viewing_as_admin_from?(request)
      Rails.application.config.manageable_subdomains.include?(request.subdomain)
    end

    def season_for(date)
      return unless date.present?

      season_name = season_name_from(date)

      {
        year: date.year,
        season: season_name,
        localized: I18n.t('anime.season.format', name: I18n.t("anime.season.#{season_name}"), year: date.year),
      }
    end

    def current_season
      season_for(Time.current).merge({ status: :airing })
    end

    def next_season
      current_date = Time.current
      current_season_code = season_code_from(current_date)

      next_season_code = (current_season_code + 1) % SEASON_CODES.count
      next_season_year = current_season_code < next_season_code ? current_date.year : current_date.year + 1

      season_name = season_name_for(next_season_code)

      {
        year: next_season_year,
        season: season_name,
        status: :coming_soon,
        localized: I18n.t('anime.season.format', name: I18n.t("anime.season.#{season_name}"), year: next_season_year),
      }
    end

    def season_code_from(date)
      case date.month
      when 1..3
        SEASON_CODES[WINTER_SEASON]
      when 4..6
        SEASON_CODES[SPRING_SEASON]
      when 7..9
        SEASON_CODES[SUMMER_SEASON]
      when 10..12
        SEASON_CODES[FALL_SEASON]
      end
    end

    def season_date_range(date)
      range = case date.month
      when 1..3
        [[1, 1], [3, 31]]
      when 4..6
        [[4, 1], [6, 30]]
      when 7..9
        [[7, 1], [9, 30]]
      when 10..12
        [[10, 1], [12, 31]]
      end

      range.map { |month_date| Date.new(date.year, *month_date) }
    end

    def season_name_from(date)
      season_name_for(season_code_from(date))
    end

    def season_name_for(code)
      SEASON_CODES.key(code)
    end
  end
end
