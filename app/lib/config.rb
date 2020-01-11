# frozen_string_literal: true

module Config
  class Error < StandardError
  end

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
  end
end
