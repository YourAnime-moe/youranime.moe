class MessagesController < ApplicationController

    before_filter {
        @inbox_options = true
    }

    def index
    end
end
