# spec/services/weather_forecast_service_spec.rb

require 'rails_helper'

RSpec.describe WeatherForecastService do
  let(:address) do
    Address.new(
      street: '123 Main St',
      city: 'San Francisco',
      state: 'CA',
      zipcode: '94105'
    )
  end

  let(:cache_key) { "irecycle:forecast:#{address.zipcode}" }

  let(:forecast_response) do
    {
      current: { temperature: 72 },
      forecast: {
        "2024-04-13" => {
          avgtemp: 70,
          mintemp: 60,
          maxtemp: 80
        }
      }
    }.deep_stringify_keys
  end

  let(:expected_result) do
    {
      current_temp: 72,
      avg_temp: 70,
      min_temp: 60,
      max_temp: 80
    }
  end

  subject { described_class.new(address: address) }

  describe '#call' do
    context 'when forecast data is in cache' do
      before do
        Rails.cache.write(cache_key, expected_result)
      end

      it 'returns cached data with using_cache: true' do
        result = subject.call
        expect(result).to include(expected_result)
        expect(result[:using_cache]).to be true
      end
    end

    context 'when forecast data is not cached' do
      before do
        Rails.cache.delete(cache_key)
        stub_request(:get, /weatherstack.com/).to_return(status: 200, body: forecast_response.to_json)
      end

      it 'fetches from API, writes to cache, and returns with using_cache: false' do
        result = subject.call

        expect(result).to include(
                            current_temp: 72,
                            avg_temp: 70,
                            min_temp: 60,
                            max_temp: 80,
                            using_cache: false
                          )

        cached = Rails.cache.read(cache_key)
        expect(cached).to include(:current_temp, :avg_temp)
      end
    end

    context 'when zipcode is missing' do
      let(:address) { Address.new(street: 'x', city: 'x', state: 'x', zipcode: nil) }

      it 'raises an error' do
        expect { subject.call }.to raise_error(ArgumentError, /Missing zipcode/)
      end
    end
  end
end