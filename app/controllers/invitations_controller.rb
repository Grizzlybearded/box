class InvitationsController < ApplicationController
before_filter :authorize_user
before_filter :has_invites

# user the sender_id when actually saving a user to save to the correct investor

  def new
  	@invitation = Invitation.new
  end

  def invite_colleagues
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
    elsif (@invitation.invite_type == true && current_user.number_invites > 0) || current_user.global_admin?
      if @invitation.save
        UserMailer.send_investor_invitation(@invitation, investor_signup_url(@invitation.token), current_user).deliver

        # decrement the user's number of invites if not the global admin
        if current_user.global_admin == false
          current_user.decrement!(:number_invites)
        end

        flash[:success] = "Thank you, invitation sent."
        redirect_to :back
      else
        render 'invite_colleagues'
      end
    else
      flash[:notice] = "You've used all your invites."
      redirect_to root_path
    end
  end

  private
    def has_invites
      redirect_to root_path unless current_user.number_invites > 0
    end
end