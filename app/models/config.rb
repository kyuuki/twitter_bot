class Config < ApplicationRecord
  validates :value, numericality: { only_integer: true, greater_than_or_equal_to: 10, less_than_or_equal_to: 99999 }, if: :is_periodical_minute?

  def is_periodical_minute?
    key == "periodical.minute"
  end
end
