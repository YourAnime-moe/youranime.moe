module Admin
  class JobEventsController < ApplicationController
    def index
      @running = JobEvent.running
      @failed = JobEvent.failed
      @complete = JobEvent.complete

      @events = JobEvent.latest
    end
  end
end
