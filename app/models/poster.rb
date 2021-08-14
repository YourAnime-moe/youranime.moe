# frozen_string_literal: true

class Poster < ApplicationRecord
  def missing?
    original == Show::DEFAULT_POSTER_URL
  end
end
