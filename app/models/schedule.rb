class Schedule < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :category

  validates :category_id, presence: true
  validates :post_time, presence: true
end
