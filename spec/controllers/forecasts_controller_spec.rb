# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ForecastsController, type: :request do
  let(:valid_params) do
    {
      street: '123 Main St',
      city: 'San Francisco',
      state: 'CA',
      zipcode: '94105'
    }
  end

  let(:invalid_params) do
    {
      street: '',
      city: '',
      state: '',
      zipcode: 'badzip'
    }
  end

  let(:cache_key) { "irecycle:forecast:94105" }

  let(:forecast_data) do
    {
      current_temp: 72,
      avg_temp: 70,
      min_temp: 60,
      max_temp: 80,
      using_cache: false
    }
  end

  before { Rails.cache.clear }

  describe 'GET /forecasts/search' do
    context 'with valid params and no cached data' do
      before do
        allow_any_instance_of(WeatherForecastService)
          .to receive(:call)
                .and_return(forecast_data)
      end

      it 'returns 200 with forecast data' do
        get '/forecasts/search', params: valid_params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json).to include(:current_temp, :avg_temp, :min_temp, :max_temp, :using_cache)
        expect(json[:using_cache]).to eq(false)
      end
    end

    context 'with valid params and cached data' do
      before do
        Rails.cache.write(cache_key, forecast_data.except(:using_cache))
      end

      it 'returns cached forecast with using_cache: true' do
        get '/forecasts/search', params: valid_params

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:using_cache]).to eq(true)
      end
    end

    context 'with invalid address params' do
      it 'returns 422 and validation errors' do
        get '/forecasts/search', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json['errors']).to be_an(Array)
        expect(json['errors']).to include("Street can't be blank", "City can't be blank", "State can't be blank", "Zipcode is invalid")
      end
    end

    context 'with missing required params' do
      it 'returns 422 with presence errors' do
        get '/forecasts/search', params: { city: 'Somewhere' }

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json['errors']).to include("Street can't be blank", "State can't be blank", "Zipcode can't be blank")
      end
    end

    context 'when WeatherForecastService raises ForecastApiError' do
      before do
        allow_any_instance_of(WeatherForecastService).to receive(:call).and_raise(ForecastApiError.new('Weather service down'))
      end

      it 'returns 503 Service Unavailable with error message' do
        get '/forecasts/search', params: valid_params

        expect(response).to have_http_status(:service_unavailable)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Weather service down')
      end
    end
  end
end