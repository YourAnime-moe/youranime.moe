require 'net/http'

class Api

	def self.value(key)
		return nil unless key and key.size > 0
		env = Config.env[key]
		return nil if env.nil?
		ENV[env]
	end

	def self.request(key)
		uris = Config.api['uris']
		uri = uris[key]
		return nil if uri.nil?
		parts = uri.split '|'
		return false if parts.size < 2
		http_method = parts[0]
		uri = parts[1]
		
		uri = api_uri(uri)
		http_class = net_http_class http_method
		req = http_class.new(uri)
		req.add_field "Authorization", "Bearer access_token"
		req.content_type = "application/x-www-form-urlencoded"
		res = Net::HTTP.start(uri.hostname, uri.port) do |http|
			http.request(req)
		end
	end

	private
		KEYS = ["client_id", "secret_id"]

		def self.api_uri(path)
			host = Config.api['host']
			path = host + path
			URI(path)
		end

		def self.net_http_class(http_method)
			base = "Net::HTTP"
			final_class = "#{base}::#{http_method}"
			begin
				Object.const_get(final_class)
			rescue NameError
				p "Invalid or non-supported http_method \"#{http_method}\""
				nil
			end
		end

end

