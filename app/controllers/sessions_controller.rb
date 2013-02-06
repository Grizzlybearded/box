class SessionsController < ApplicationController

  def new
    if !current_user.nil?
      redirect_to root_url, notice: "Already logged in"
    end
  end

  def create
    if current_user.nil?
  	 user = User.find_by_email(params[:email])
  	 if user && user.authenticate(params[:password])
  	 	 session[:user_id] = user.id
  		  redirect_to root_url, notice: "Logged in!"
  	 else
  		  flash.now.alert = "Email or password is invalid"
  		  render 'new'
  	 end
    else
      redirect_to root_url, notice: "Already logged in"
    end
  end

  def destroy
  	session[:user_id] = nil
  	redirect_to root_url, notice: "Logged out"
  end

end
