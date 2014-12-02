require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'

URL = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/projects/test_project/cards.xml'
OPTIONS = {:access_key_id => '<MINGLE USERNAME>', :access_secret_key => '<MINGLE HMAC KEY>'}

def http_get(url, options={})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    
    ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])

    response = http.request(request)

    cards = response.body

    if response.code.to_i > 300
      raise UnexpectedResponseError, <<-ERROR
      Request URL: #{url}
      Response: #{response.code} #{response.message}
      Response Headers: #{response.to_hash.inspect}\nResponse Body: #{response.body}"
      ERROR
    end

    return cards
end

http_get(URL, OPTIONS)