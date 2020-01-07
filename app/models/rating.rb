class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :show

  def self.global
    average(:value).to_f
  end
end
