class Schedule < ApplicationRecord
  validates :category, presence: true
  validates :post_time, presence: true
end
