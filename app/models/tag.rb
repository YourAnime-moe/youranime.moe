# frozen_string_literal: true
class Tag < ApplicationRecord
  has_many :shows_tag_relations, inverse_of: :tags

  VALID_TAGS = Utils.valid_tags
  validates_inclusion_of :value, in: VALID_TAGS

  validates_uniqueness_of :value
end
