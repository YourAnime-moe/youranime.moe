# frozen_string_literal: true
module Admin
  class JobEventsController < ApplicationController
    def index
      @running = JobEvent.running
      @finished = JobEvent.finished.paginate(page: params[:page])
    end
  end
end
