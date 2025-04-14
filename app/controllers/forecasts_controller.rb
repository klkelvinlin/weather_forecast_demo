# frozen_string_literal: true

class ForecastsController < ApplicationController

  # Before executing the `search` action, we must:
  # 1. Build an address object from incoming parameters
  # 2. Validate the address to ensure it's complete and properly formatted
  before_action :set_address, only: [:search]
  before_action :validate_address, only: [:search]

  def index
  end

  # GET /forecasts/search
  # Main entry point to retrieve a weather forecast.
  # Delegates to the service object which handles caching and external API communication.
  # If the forecast is retrieved successfully, it renders the result as JSON.
  # If there's a failure in connecting to the weather API, it rescues and returns a 503 error.
  def search
    render json: WeatherForecastService.new(address: @address).call
  rescue ForecastApiError => e
    render json: { error: e.message }, status: :service_unavailable
  end

  private

  # Strong parameters: Only allow the specific address-related params we expect.
  # This prevents injection of unwanted parameters from the client.
  def address_params
    params.permit(:street, :city, :state, :zipcode)
  end

  # Initializes an `Address` object using permitted parameters.
  # The Address model includes validation logic and is used as an input object for the service.
  def set_address
    @address = Address.new(address_params)
  end

  # Validates the address before proceeding with the search.
  # If the address is invalid (missing fields or malformed zipcode),
  # return a 422 Unprocessable Entity with validation error messages.
  def validate_address
    return if @address.valid?

    render json: { errors: @address.errors.full_messages }, status: :unprocessable_entity
  end
end
