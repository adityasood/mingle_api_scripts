require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'

URL = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/projects/<project name>/cards/<card num>/murmurs.xml'
OPTIONS = {:access_key_id => '<LOGIN IN NAME>', :access_secret_key => '<HMAC SECRET KEY>'}

def http_get(url, options={})
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri.request_uri)
  ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])

  response = http.request(request)
  murmurs = response.body

  if response.code.to_i > 300
    raise StandardError, <<-ERROR
    Request URL: #{url}
    Response: #{response.code}
    Response Message: #{response.message}
    Response Headers: #{response.to_hash.inspect}
    Response Body: #{response.body}
    ERROR
  end
  
  puts murmurs 

end

http_get(URL, OPTIONS)