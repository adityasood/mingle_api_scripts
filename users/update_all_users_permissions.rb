require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'
require 'nokogiri'

all_users_url = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/users.xml'
keys = {:access_key_id => '<MINGLE USERNAME>', :access_secret_key => '<MINGLE HMAC KEY>'}


def http_get(url, keys={})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    ApiAuth.sign!(request, keys[:access_key_id], keys[:access_secret_key])
    response = http.request(request)

    if response.code.to_i > 300
        raise StandardError, <<-ERROR
        Request URL: #{url}
        Response: #{response.code}
        Response Message: #{response.message}
        Response Headers: #{response.to_hash.inspect}
        Response Body: #{response.body}
        ERROR
    end

    return response
end

def parse(response)
  xml = Nokogiri::XML(response.body)
  
  user_ids = []
  xml.css('user').each {|user| user_ids << user.at_css('id').content }
  
  return user_ids.sort!
end

def ask_for_id(user_arr)
  puts "What's the user ID of the user updating?"
  admin = gets.chomp

  user_arr.delete_if{|x| x == admin }

  return user_arr
end

def http_put(user_array)
  user_array.each do |user|
    url = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/users/' + user + '.xml'
    OPTIONS = {:access_key_id => '<MINGLE USERNAME>', :access_secret_key => '<MINGLE HMAC KEY>'}

    params = { :user => { :activated => false } }

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    body = params.to_json

    request = Net::HTTP::Put.new(uri.request_uri)
    request.body = body
    request['Content-Type'] = 'application/json'
    request['Content-Length'] = body.bytesize
    ApiAuth.sign!(request, keys[:access_key_id], keys[:access_secret_key])
    
    response = http.request(request)

    if response.code.to_i > 300
        raise StandardError, <<-ERROR
        Request URL: #{url}
        Response: #{response.code}
        Response Message: #{response.message}
        Response Headers: #{response.to_hash.inspect}
        Response Body: #{response.body}
        ERROR
    end
  end
end

response = http_get(all_users_url, keys)
user_id_array = parse(response)
correct_arr = ask_for_id(user_id_array)
http_put(correct_arr)
