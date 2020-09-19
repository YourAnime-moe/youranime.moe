module Admin
  class UsersController < ApplicationController
    include Admin::UsersHelper

    def index
      @users = if params[:oauth] == 'true'
        set_title(before: 'OAuth Users')
        User.where(user_type: [User::GOOGLE, User::MISETE])
      else
        set_title(before: 'Users')
        User.all
      end
    end

    def update
    end
  end

  private
end
