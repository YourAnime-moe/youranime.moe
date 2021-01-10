# frozen_string_literal: true
class Tag < ApplicationRecord
  has_many :shows_tag_relations, inverse_of: :tags
end
