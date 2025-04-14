# frozen_string_literal: true

# Service object responsible for retrieving and returning weather forecast data
# for a given address. It handles caching, external API requests, and fallback logic.
class WeatherForecastService < BaseService

  # Initialize the service with an Address object.
  # The Address must respond to `street`, `city`, `state`, and `zipcode`.
  def initialize(address:)
    @address = address
  end

  # Main entry point for consumers of this service.
  # 1. Attempts to read from cache first using the ZIP code as key.
  # 2. If cache is found, returns it with `using_cache: true`.
  # 3. Otherwise, fetches fresh data from the external weather API,
  #    stores it in cache, and returns it with `using_cache: false`.
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

  # Makes an external API request to retrieve the forecast data.
  # Parses and normalizes the returned JSON to extract:
  # - current temperature
  # - average, min, and max forecasted temperatures
  #
  # Handles and logs connection issues and timeouts, and raises a custom error
  # so the controller can respond appropriately.
  def fetch_forecast_from_api
    response = conn.get('/forecast', { 'access_key': ENV['WEATHER_STACK_API_KEY'], 'query': full_address })

    # Symbolizing keys for easier access
    data = response.body.deep_symbolize_keys

    # Dig into the forecast hash for today's data (first day in response)
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

  # Builds the full street address from the Address object.
  # Ensures the string is URL-safe using URI encoding.
  # Used in the query string for the weather API.
  def full_address
    # Construct the full address string
    full_address = "#{@address.street}, #{@address.city}, #{@address.state} #{@address.zipcode}"

    # URL-encode it safely
    URI.encode_www_form_component(full_address)
  end

end