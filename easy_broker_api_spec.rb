require 'rspec'
require_relative 'easy_broker_api'
require 'json'

RSpec.describe EasyBrokerAPI do
  let(:api_key) { 'l7u502p8v46ba3ppgvj5y2aad50lb9' }
  let(:http_client) { double('Net::HTTP') }
  let(:api) { EasyBrokerAPI.new(api_key, http_client) }
  let(:url) { URI("#{EasyBrokerAPI::BASE_URL}?page=1&limit=20") }

  describe '#fetch_properties' do
    context 'when the API returns properties' do
      it 'returns a list of property titles' do
        # Mockear la respuesta HTTP
        response = double('Net::HTTPResponse', code: '200', body: {
          "content" => [
            { "title" => "Casa bien bonita" },
            { "title" => "Casa en Venta en Infonavit Fidel Velazquez en San Nicolás de los Garza" },
            { "title" => "Casa en Venta con terreno para Sembrar en Cadereyta, N.L." }
          ]
        }.to_json)

        allow(http_client).to receive(:new).and_return(http_client)
        allow(http_client).to receive(:use_ssl=).with(true)
        allow(http_client).to receive(:request).and_return(response)

        titles = api.fetch_properties
        expect(titles).to eq(["Casa bien bonita", "Casa en Venta en Infonavit Fidel Velazquez en San Nicolás de los Garza", "Casa en Venta con terreno para Sembrar en Cadereyta, N.L."])
      end
    end

    context 'when the API returns an error' do
      it 'raises an error when the response code is not 200' do
        response = double('Net::HTTPResponse', code: '500', message: 'Internal Server Error')

        allow(http_client).to receive(:new).and_return(http_client)
        allow(http_client).to receive(:use_ssl=).with(true)
        allow(http_client).to receive(:request).and_return(response)

        expect { api.fetch_properties }.to raise_error("Error al obtener propiedades: 500 - Internal Server Error")
      end
    end

    context 'when the API returns no properties' do
      it 'returns a message indicating no properties were found' do
        response = double('Net::HTTPResponse', code: '200', body: { "content" => [] }.to_json)

        allow(http_client).to receive(:new).and_return(http_client)
        allow(http_client).to receive(:use_ssl=).with(true)
        allow(http_client).to receive(:request).and_return(response)

        result = api.fetch_properties
        expect(result).to eq("No found properties.")
      end
    end
  end
end
