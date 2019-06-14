# frozen_string_literal: true

class AdminController < AuthenticatedController
  before_action :ensure_is_admin

  layout 'admin'

  def home
    redirect_to admin_shows_url
  end

  protected

  def ensure_is_admin
    (flash[:danger] = 'Sorry, you need to be logged in as an admin user!'; redirect_to '/') unless current_user.admin?
  end
end
