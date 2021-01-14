# frozen_string_literal: true

class ShowCardComponent < ViewComponent::Base
  attr_reader :show, :platform

  def initialize(show, platform: nil)
    @show = show
    @platform = platform

    super
  end
end
