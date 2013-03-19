class UserMailer < ActionMailer::Base
  default from: "analyst@hfanalyst.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.fund_data_imported.subject
  #

  def new_user_mail(user)
    @user = user
    mail to: @user.email, subject: "Welcome to HF Analyst"
  end

  def send_invitation(invitation, signup_url, current_user)
    @current_user = current_user
    @invitation = invitation
    @signup_url = signup_url
    @invitation.update_attributes(sent_at: Time.now)
    mail to: @invitation.recipient_email, subject: "You've been added to HF Analyst"
  end

  def fund_data_imported(user, fund)
    @user = user
    @fund = fund
    mail to: @user.investor.users.pluck(:email), subject: "Data uploaded for #{@fund.name}"
  end
end