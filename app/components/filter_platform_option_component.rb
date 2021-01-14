# frozen_string_literal: true

class FilterPlatformOptionComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers
  attr_reader :platform, :current_platform

  def initialize(platform, current_platform: nil)
    @platform = platform
    @current_platform = current_platform

    super
  end

  def button_classes
    classes = ['button', 'is-small']
    classes << if active?
      'is-light'
    else
      'is-dark'
    end

    classes.join(' ')
  end

  def filter_path
    active? ? schedule_platforms_path : schedule_platforms_path(name: platform.name)
  end

  def active?
    current_platform.present? && current_platform.name == platform.name
  end
end
