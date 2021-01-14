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

  def schedule
    options = if current_platform
      [current_platform, :home, :platforms, :schedule]
    else
      [:schedule, :home, :platforms]
    end

    breadcrumbs(*options)
    set_title(before: 'Release schedule')

    @raw_schedule, @results = Shows::ReleaseSchedule.perform(platform: current_platform)
  end
end
