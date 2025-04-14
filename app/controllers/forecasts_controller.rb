# frozen_string_literal: true

class ForecastsController < ApplicationController

  before_action :set_address, only: [:search]
  before_action :validate_address, only: [:search]

  def index
  end

  def search
    render json: WeatherForecastService.new(address: @address).call
  end

  private

  def set_address
    @address = Address.new(params)
  end

  def validate_address
    head :unprocessable_entity unless @address.valid?
  end
end
