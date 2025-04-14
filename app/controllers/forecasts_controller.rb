# frozen_string_literal: true

class ForecastsController < ApplicationController

  before_action :set_address, only: [:search]
  before_action :validate_address, only: [:search]

  def index
  end

  def search
    render json: WeatherForecastService.new(address: @address).call
  rescue ForecastApiError => e
    render json: { error: e.message }, status: :service_unavailable
  end

  private

  def address_params
    params.permit(:street, :city, :state, :zipcode)
  end

  def set_address
    @address = Address.new(address_params)
  end

  def validate_address
    return if @address.valid?

    render json: { errors: @address.errors.full_messages }, status: :unprocessable_entity
  end
end
