# frozen_string_literal: true

class BadgeComponent < ViewComponent::Base
  def initialize(content:, colour: nil, background: nil, type: nil, light: false)
    @type = type
    @colour = colour
    @background = background
    @content = content
    @light = light
  end

  def attributes
    classes = []
    classes << "#{@type}" if @type
    classes << 'is-light' if @light

    classes.join(' ')
  end
end
