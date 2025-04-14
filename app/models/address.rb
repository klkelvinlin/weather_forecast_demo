# frozen_string_literal: true
require 'ostruct'
class Address < OpenStruct
  attr_accessor :street, :city, :state, :zipcode

  def initialize(params)
    @street = params[:street]
    @city = params[:city]
    @state = params[:state]
    @zipcode = params[:zipcode]
  end

  def valid_zipcode?
    @zipcode.match?(/\A\d{5}(-\d{4})?\z/)
  end

  def valid?
    return false if @street.blank? || @city.blank? || @state.blank? || @zipcode.blank?
    valid_zipcode?
  end
end
