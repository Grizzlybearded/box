class InvitationsController < ApplicationController
before_filter :authorize_user

# user the sender_id when actually saving a user to save to the correct investor

  def new
  	@invitation = Invitation.new
  end

  def create
  	@invitation = Invitation.new(params[:invitation])
  	@invitation.sender = current_user
  	if @invitation.invite_type == false
      if @invitation.save
    		UserMailer.send_invitation(@invitation, signup_url(@invitation.token), current_user).deliver
    		flash[:success] = "Thank you, invitation sent."
    		redirect_to :back
    	else
    		render 'new'
    	end
    elsif @invitation.invite_type == true
      if @invitation.save
        UserMailer.send_investor_invitation(@invitation, investor_signup_url(@invitation.token), current_user).deliver
        flash[:success] = "Thank you, invitation sent."
        redirect_to :back
      else
        render 'invite_colleagues'
      end

    end
  end

  def invite_colleagues
    @invitation = Invitation.new
  end
end