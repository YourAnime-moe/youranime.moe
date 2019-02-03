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

    class << self
        # <protocol>://<subdomain>.<domain>:<port>/<path>
        def main_host(as_is: false)
          raise Error.new('Please set the domain name.') if domain.nil?
          _protocol = use_ssl ? 'https' : (protocol || 'http')
          _port = use_ssl ? 443 : (port || 80)
          host = ''
          host = _protocol + '://' unless as_is
          host << (sub_domain + '.') if sub_domain
          host << domain
          host << (":#{_port}") unless port.nil?
          host
        end

        def path(path, as_is: false)
            main = self.main_host(as_is: as_is).dup
            return path if main.blank?
            if !main.end_with? "/" and !path.start_with? "/"
                main << "/"
            end
            main + path
        end

        def setup
          yield self
        end
    end
end
