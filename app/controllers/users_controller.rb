class UsersController < ApplicationController
before_filter :authorize_user, except: [:new, :create]
before_filter :authorize_ga, except: [:new, :create, :edit, :update, :destroy]
before_filter :correct_user, only: [:edit, :update]
before_filter :same_investor, except: [:index, :new, :create]

	def new
		@user = User.new(:invitation_token => params[:invitation_token])
		@user.email = @user.invitation.recipient_email if @user.invitation
		@investor = User.find_by_id(@user.invitation.sender_id).investor
	end

	def create
		@user = User.new(params[:user])


		#do i need to validate that the invitation is real?  am i already doing that?

		#before_filter :same investor won't work here so the test to ensure the same investor is done below
		if @user.invitation.invite_type == false	
			if @user.investor_id == User.find_by_id(@user.invitation.sender_id).investor_id &&
				@user.email == @user.invitation.recipient_email
				if @user.save
					UserMailer.new_user_mail(@user).deliver
					redirect_to root_url, notice: "New user created!"
				else
					render 'new'
				end
			else
				flash[:notice] = "You can only create users that work at the same company as you."
				redirect_to :back
			end
		elsif @user.invitation.invite_type == true
			@user.investor_id = Investor.find_by_invitation_token(@user.invitation.token).id
			if @user.save
				UserMailer.new_user_mail(@user).deliver
				redirect_to root_url, notice: "New user created!"
			else
				render 'new'
			end
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