require 'net/http'
require 'uri'

uri = URI.parse("https://myanimelist.net/api/anime/search.json?q=naruto")
request = Net::HTTP::Get.new(uri)
request.basic_auth("tanoshimu-anime", "tanoshimu-apps")

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

p response.code
p response.body

