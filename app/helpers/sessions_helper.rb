module SessionsHelper

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def current_user?(user)
		user == current_user
	end

	def authorize_user
		redirect_to login_url, alert: "Please sign in" if current_user.nil?
	end
	
	def authorize_ga
		redirect_to root_url, alert: "Not authorized" if !current_user.global_admin?
	end

	def signed_in?
		!current_user.nil?
 	end
end
