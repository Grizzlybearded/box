class UsersController < ApplicationController
before_filter :authorize_user
before_filter :authorize_ga, except: [:new, :create, :edit, :update, :destroy]
before_filter :correct_user, only: [:edit, :update]
before_filter :same_investor, except: [:index, :new, :create]

	def new
		@user = User.new
	end

	def create
		@user = User.new(params[:user])
		#before_filter :same investor won't work here so the test to ensure the same investor is done below
		if @user.investor_id == current_user.investor_id
			if @user.save
				redirect_to current_user.investor, notice: "New user created!"
			else
				render 'new'
			end
		else
			flash[:notice] = "You can only create users that work at the same company as you."
			redirect_to :back
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
			flash[:success] = "User details updated"
			redirect_to root_path
		else
			render 'edit'
		end
	end

	def destroy
		User.find(params[:id]).destroy
		flash[:success] = "User deleted"
		redirect_to current_user.investor
	end

	private
		def correct_user
			@user = User.find(params[:id])
			redirect_to root_path unless current_user == @user
		end

		def same_investor
			@user = User.find(params[:id])
			redirect_to root_path unless @user.investor == current_user.investor
		end
end