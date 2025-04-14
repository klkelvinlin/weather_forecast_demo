# frozen_string_literal: true

class WeatherForecastService < BaseService

  def initialize(address:)
    @address = address
  end

  def call
    cached = read_cached_forecast
    return cached.merge(using_cache: true) if cached.present?

    forecast = fetch_forecast_from_api
    Rails.cache.write(cache_key, forecast, expires_in: 30.minutes)
    forecast.merge(using_cache: false)
  end

  private

  def cache_key
    raise ArgumentError, 'Missing zipcode' if @address.zipcode.blank?
    "irecycle:forecast:#{@address.zipcode}"
  end

  def read_cached_forecast
    Rails.cache.read(cache_key) || {}
  end

  def fetch_forecast_from_api
    response = conn.get('/forecast', { 'access_key': ENV['WEATHER_STACK_API_KEY'], 'query': full_address })
    data = JSON.parse(response.body).deep_symbolize_keys
    forecast_data = data.dig(:forecast)&.values&.first || {}
    {
      current_temp: data.dig(:current, :temperature),
      avg_temp: forecast_data[:avgtemp],
      min_temp: forecast_data[:mintemp],
      max_temp: forecast_data[:maxtemp]
    }
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error("Weather API connection failed: #{e.message}")
    raise ForecastApiError, 'Unable to connect to weather service'
  rescue Faraday::TimeoutError => e
    Rails.logger.error("Weather API timed out: #{e.message}")
    raise ForecastApiError, 'Weather service timeout'
  end

  def full_address
    # Construct the full address string
    full_address = "#{@address.street}, #{@address.city}, #{@address.state} #{@address.zipcode}"

    # URL-encode it safely
    URI.encode_www_form_component(full_address)
  end

end