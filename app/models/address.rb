# frozen_string_literal: true

class Address
  include ActiveModel::Model
  attr_accessor :street, :city, :state, :zipcode

  validates :street, :city, :state, :zipcode, presence: true
  validate :zipcode_format

  def full_address
    "#{street}, #{city}, #{state} #{zipcode}"
  end

  private

  def zipcode_format
    unless zipcode.to_s.match?(/\A\d{5}(-\d{4})?\z/)
      errors.add(:zipcode, "is invalid")
    end
  end
end