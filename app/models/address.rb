# frozen_string_literal: true

# Address is a plain Ruby object that represents a mailing address
# used to request weather forecasts.
#
# It includes ActiveModel::Model to:
# - Enable validations similar to ActiveRecord
# - Support form objects and controller validations
#
# This object is **not an active record**.
class Address
  include ActiveModel::Model
  attr_accessor :street, :city, :state, :zipcode

  # -------------------------
  # VALIDATIONS
  # -------------------------

  # Ensure all fields are provided.
  validates :street, :city, :state, :zipcode, presence: true

  # Custom validator to ensure the ZIP code is well-formed.
  # Accepts both 5-digit and 9-digit ZIP+4 formats.
  validate :zipcode_format

  # Combines the individual address fields into a single formatted string.
  # This is used when querying the external weather API.
  #
  # Example output:
  #   "123 Main St, San Francisco, CA 94105"
  def full_address
    "#{street}, #{city}, #{state} #{zipcode}"
  end

  private

  # Validates the ZIP code format.
  # Supports:
  #   - 5-digit ZIP (e.g., "94105")
  #   - 9-digit ZIP+4 (e.g., "94105-1234")
  #
  # If invalid, adds a human-friendly error message to the `zipcode` field.
  def zipcode_format
    unless zipcode.to_s.match?(/\A\d{5}(-\d{4})?\z/)
      errors.add(:zipcode, "is invalid")
    end
  end
end