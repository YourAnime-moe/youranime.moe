# frozen_string_literal: true

class BadgeComponent < ViewComponent::Base
  def initialize(content:, colour: nil, background: nil, type: nil, light: false, style: nil)
    @type = type
    @colour = colour
    @background = background
    @content = content
    @light = light
    @style = style
  end

  def attributes
    classes = []
    classes << @type.to_s if @type
    classes << 'is-light' if @light

    classes.join(' ')
  end
end
