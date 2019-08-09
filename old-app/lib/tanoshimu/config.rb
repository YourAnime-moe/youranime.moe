module Tanoshimu

  module Config
    class << self
      def url
        Config::URL.to_s
      end
      def url=(new_url)
        to_set = URI.parse(new_url)
        return nil if to_set.scheme.nil?
        Config::URL.domain = to_set.host
        Config::URL.port = to_set.port
        Config::URL.protocol = to_set.scheme.to_sym
        url
      end
    end

    module URL
      mattr_accessor :protocol
      @@protocol = :https

      mattr_accessor :domain
      @@domain = nil

      mattr_accessor :port
      @@port = nil

      class << self
        def to_s
          raise Exception.new('Please set the domain.') if domain.blank?
          url = "#{protocol}://#{domain}"
          url << ":#{port}" if port.to_i > 0
          url
        end
        def inspect
          url = "#{protocol}://#{domain || '<not set>'}"
          url << ":#{port}" if port.to_i > 0
          url
        end
      end
    end
  end

end
