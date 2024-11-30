require 'json'
require 'net/http'

class EasyBrokerAPI
  BASE_URL = 'https://api.stagingeb.com/v1/properties'

  def initialize(api_key, http_client = nil)
    @api_key = api_key
    @http_client = http_client || Net::HTTP
  end

  def fetch_properties
    url = URI("#{BASE_URL}?page=1&limit=20")
    http = @http_client.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["X-Authorization"] = @api_key

    response = http.request(request)

    case response.code.to_i
    when 200
      data = JSON.parse(response.body)
      properties = data["content"]
      if properties.nil? || properties.empty?
        "No found properties."
      else
        properties.map { |property| property["title"] }
        #puts "Propiedades encontradas:"
        #properties.each_with_index do |property, index|
          #puts "#{index + 1}. #{property['title']}"
        #end
        #puts "Final de la lista de propiedades."
      end
    else
      raise "Error for gets properties: #{response.code} - #{response.message}"
    end
  end
end

# Instanciar la clase y probar
api = EasyBrokerAPI.new('l7u502p8v46ba3ppgvj5y2aad50lb9')
api.fetch_properties