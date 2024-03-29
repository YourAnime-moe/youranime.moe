# frozen_string_literal: true
class ShowsTagRelation < ApplicationRecord
  belongs_to :tag, inverse_of: :shows_tag_relations
  has_many :shows, inverse_of: :shows_tag_relation
end
