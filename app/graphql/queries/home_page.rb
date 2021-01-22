# frozen_string_literal: true
module Queries
  module HomePage
    field :test, String, null: false

    def test
      'test!!!'
    end
  end
end
