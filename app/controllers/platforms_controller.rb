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
    unless can_show_full_release_schedule?
      redirect_to(platforms_path)
      return
    end

    options = if current_platform
      [current_platform, :home, :platforms, :schedule]
    else
      [:schedule, :home, :platforms]
    end

    breadcrumbs(*options)
    set_title(before: 'Release schedule')

    @dates, @results, @total_count = Shows::ReleaseSchedule.perform(platform: current_platform)
  end
end
