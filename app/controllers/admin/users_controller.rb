# frozen_string_literal: true
module Admin
  class UsersController < ApplicationController
    include Admin::UsersHelper

    def index
      @users = if params[:oauth] == 'true'
        set_title(before: 'OAuth Users')
        GraphqlUser.all
      else
        set_title(before: 'Users')
        User.all
      end
    end

    def update
    end
  end
end
