# frozen_string_literal: true
class PlatformsController < ApplicationController
  include PlatformsHelper

  def index
    breadcrumbs(:platforms, :home)
  end

  def show
    breadcrumbs(current_platform, :home, :platforms)
  end
end
