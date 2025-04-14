# frozen_string_literal: true

class WeatherForecastService < BaseService

  def initialize(address:)
    @address = address
  end

  def cached_forecast
    key = cache_key(@address.zipcode)
    ap 'cached_forecast...'
    ap key
    Rails.cache.read(key) || {}
  end

  def api_forecast
    data = conn.get('/forecast', { 'access_key': ENV['WEATHER_STACK_API_KEY'], 'query': full_address }).to_hash.deep_symbolize_keys.dig(:body)
    current_temp_hash = data[:current]
    forecast_temp_hash = data[:forecast].values.first
    @raw_response ||= { current_temp: current_temp_hash[:temperature],
                        avg_temp: forecast_temp_hash[:avgtemp],
                        min_temp: forecast_temp_hash[:mintemp],
                        max_temp: forecast_temp_hash[:maxtemp] }
  end

  def call
    ap 'call...'
    ap cached_forecast
    ap cached_forecast.present?
    if cached_forecast.present?
      cached_forecast.merge({ using_cache: true })
    else
      Rails.cache.write(cache_key(@address.zipcode), api_forecast, expires_in: 30.minutes)
      api_forecast.merge({ using_cache: false })
    end
  end

  private

  def cache_key(zipcode)
    "irecycle:forecast:#{zipcode}"
  end

  def full_address
    # Construct the full address string
    full_address = "#{@address.street}, #{@address.city}, #{@address.state} #{@address.zipcode}"

    # URL-encode it safely
    URI.encode_www_form_component(full_address)
  end

end