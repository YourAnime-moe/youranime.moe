module Config

  class Error < StandardError
  end

  mattr_accessor :protocol
  @@protocol = nil

  mattr_accessor :use_ssl
  @@use_ssl = true

  mattr_accessor :sub_domain
  @@sub_domain = nil

  mattr_accessor :domain
  @@domain = nil

  mattr_accessor :port
  @@port = nil

  mattr_accessor :use_env
  @@use_env = false

  mattr_accessor :videojs
  @@videojs = nil

  mattr_accessor :api_version
  @@api_version = nil

  mattr_accessor :bulma_version
  @@bulma_version = nil

  class << self
    # <protocol>://<subdomain>.<domain>:<port>/<path>
    def main_host(as_is: false)
      return if domain.nil?
      _protocol = use_ssl ? 'https' : (protocol || 'http')
      _port = use_ssl ? 443 : (port || 80)
      host = ''
      host = _protocol + '://' unless as_is
      host << (sub_domain + '.') if sub_domain
      host << domain
      host << (":#{_port}") unless port.nil?
      host
    end

    def slack_client
      return @slack_client unless @slack_client.nil?
      @slack_client = Slack::Web::Client.new
      begin
        @slack_client.auth_test
      rescue Slack::Web::Api::Errors::SlackError => e
        warn "Could not auth to Slack. Are you connected?"
        @slack_client = nil
      end
    end

    def path(path, as_is: false)
      main = self.main_host(as_is: as_is).dup
      return path if main.blank?
      if !main.end_with? "/" and !path.start_with? "/"
        main << "/"
      end
      main + path
    end

    def google_client_id
      ENV["GOOGLE_OAUTH_CLIENT_ID"]
    end

    def setup
      yield self
    end
  end
end
