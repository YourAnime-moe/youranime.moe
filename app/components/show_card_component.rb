# frozen_string_literal: true

class ShowCardComponent < ViewComponent::Base
  attr_reader :show, :platform

  def initialize(show, platform: nil, link: false)
    @show = show
    @platform = platform
    @link = link

    super
  end

  def internal_container
    if @link
      link_to(show) do
        yield
      end
    else
      yield
    end
  end
end
