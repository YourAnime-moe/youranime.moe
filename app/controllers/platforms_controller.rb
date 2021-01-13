# frozen_string_literal: true
class PlatformsController < ApplicationController
  include PlatformsHelper

  def index
    breadcrumbs(:platforms, :home)
    set_title(before: 'Available Streaming Platforms')
  end

  def show
    breadcrumbs(current_platform, :home, :platforms)
    set_title(before: current_platform.title, after: 'Available Streaming Platforms')
  end
end
