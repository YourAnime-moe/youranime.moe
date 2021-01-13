# frozen_string_literal: true
module Shows
  class PlatformsController < ApplicationController
    include PlatformsHelper

    def index
      breadcrumbs(:platform, :shows)
    end

    def show
      breadcrumbs(current_platform, :shows, :platforms)
    end
  end
end
