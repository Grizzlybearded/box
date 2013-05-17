module SessionsHelper

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def current_user?(user)
		user == current_user
	end

	def authorize_user
		unless signed_in?
			store_location
			redirect_to login_url, alert: "Please sign in"
		end
	end
	
	def authorize_ga
		redirect_to root_url, alert: "Not authorized" if !current_user.global_admin?
	end

	def signed_in?
		!current_user.nil?
 	end

 	def redirect_back_or(default)
    	redirect_to(session[:return_to] || default)
    	session.delete(:return_to)
    	flash[:notice] = "Logged in!"
  	end

  	def store_location
    	session[:return_to] = request.url
  	end
end
