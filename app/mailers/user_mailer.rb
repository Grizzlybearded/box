class UserMailer < ActionMailer::Base
  default from: "analyst@hfanalyst.com"
  helper :funds

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.fund_data_imported.subject
  #

  def new_user_mail(user)
    @user = user
    @root_url = root_url
    mail to: @user.email, subject: "Welcome to HF Analyst"
  end

  def send_invitation(invitation, signup_url, current_user)
    @current_user = current_user
    @invitation = invitation
    @signup_url = signup_url
    @invitation.update_attributes(sent_at: Time.now)
    mail to: @invitation.recipient_email, subject: "You've been added to HF Analyst"
  end

  def send_investor_invitation(invitation, inv_signup_url, current_user)
    @current_user = current_user
    @invitation = invitation
    @investor_signup_url = inv_signup_url
    @invitation.update_attributes(sent_at: Time.now)
    mail to: @invitation.recipient_email, subject: "You've been invited to HF Analyst"
  end

  def fund_data_imported(user, fund)
    @user = user
    @fund = fund
    mail to: @user.investor.users.pluck(:email), subject: "Data uploaded for #{@fund.name}"
  end

  def beta_email(user)
    @user = user
    @funds = @user.investor.funds.where(retired: false).order("name").includes(:months)
    @fund_ids = @user.investor.funds.where(retired: false).pluck(:fund_id)
    @last_month = Month.where(fund_id: @fund_ids).maximum(:mend)

    @acwi = Fund.find_by_name("MSCI ACWI")
    @root_url = root_url

    mail to: @user.email, subject: "Beta to MSCI ACWI - HF Analyst"
  end
end