# frozen_string_literal: true

class BadgeComponent < ViewComponent::Base
  def initialize(type:, content:, light: false)
    @type = type
    @content = content
    @light = light
  end

  def attributes
    classes = []
    classes << "#{@type}"
    classes << 'is-light' if @light

    classes.join(' ')
  end
end
