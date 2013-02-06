class UsersController < ApplicationController
before_filter :authorize_user
before_filter :authorize_ga

	def create
		@user = User.new(params[:user])
		if @user.save
			redirect_to :back, notice: "New user created!"
		else
			render 'new'
		end
	end

	def index
		@users = User.all
	end

	def edit
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		if @user.update_attributes(params[:user])
			flash[:success] = "User updated"
			redirect_to users_path
		else
			render 'edit'
		end
	end

	def destroy
		User.find(params[:id]).destroy
		flash[:success] = "User destroyed"
		redirect_to users_path
	end

end
