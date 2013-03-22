class InvitationsController < ApplicationController
before_filter :authorize_user

# user the sender_id when actually saving a user to save to the correct investor

  def new
  	@invitation = Invitation.new
  end

  def create
  	@invitation = Invitation.new(params[:invitation])
  	@invitation.sender = current_user
  	if @invitation.save
  		UserMailer.send_invitation(@invitation, signup_url(@invitation.token), current_user).deliver
  		flash[:success] = "Thank you, invitation sent."
  		redirect_to :back
  	else
  		flash[:notice] = "Invitation not sent."
  		render 'new'
  	end
  end
end