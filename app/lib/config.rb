# frozen_string_literal: true

module Config
  class Error < StandardError
  end

  mattr_accessor :videojs	
  @@videojs = nil

  class << self
    def slack_client
      return @slack_client unless @slack_client.nil?

      @slack_client = Slack::Web::Client.new
      begin
        @slack_client.auth_test
      rescue Slack::Web::Api::Errors::SlackError
        warn 'Could not auth to Slack. Are you connected?'
        @slack_client = nil
      end
    end

    def demo?
      ENV['DEMO'].to_s.downcase.strip == 'true'
    end

    def google_client_id	
      ENV['GOOGLE_OAUTH_CLIENT_ID']	
    end	

    def uses_disk_storage?	
      Rails.application.config.active_storage.service == :local
    end
  end
end
