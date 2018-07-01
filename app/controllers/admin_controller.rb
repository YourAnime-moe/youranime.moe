class AdminController < AuthenticatedController
	before_action :ensure_is_admin

	def home
		redirect_to admin_shows_url
	end

	protected

	def ensure_is_admin
		unless current_user.is_admin?
			flash[:danger] = "Sorry, you need to be logged in as an admin user!"
        	redirect_to '/';
        end
	end
end
