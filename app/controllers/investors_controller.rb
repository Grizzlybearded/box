class InvestorsController < ApplicationController
  before_filter :authorize_user, except: [:new, :create]
  before_filter :authorize_ga, except: [:show, :new, :create]
  before_filter :correct_user, only: [:show]
  #the authorize_ga and correct_user before_filters work together to create the desired restrictions

  def new
  	@investor = Investor.new(:invitation_token => params[:invitation_token])
    @user = @investor.users.build(:invitation_token => params[:invitation_token])
    @user.email = @user.invitation.recipient_email if @user.invitation
  end

#restrict user from joining another investor
#restrict user from being created without investor
#restrict investor from being created without user

  def create
  	@investor = Investor.new(params[:investor])
      if @investor.save
        #subscribe to all the core benchmarks
        Fund.where(core_bmark: true).each do |f|
          f.relationships.build(investor_id: @investor.id).save
        end

        #subscribe to all the starter funds
        Fund.where(starter_fund: true).each do |f|
          f.relationships.build(investor_id: @investor.id).save
        end

    		flash[:success] = "New investor created!"
    		redirect_to investors_path
    	else
    		render 'new'
    	end
  end

  def edit
  	@investor = Investor.find(params[:id])
  end

  def update
  	@investor = Investor.find(params[:id])
  	if @investor.update_attributes(params[:investor])
  		flash[:success] = "Investor updated"
  		redirect_to investors_path
  	else
  		render 'edit'
  	end
  end

  def index
  	@investors = Investor.all
  end

  def show
    @investor = Investor.find(params[:id])
    @user = @investor.users.build
  end

  def destroy
  	Investor.find(params[:id]).destroy
  	flash[:success] = "Investor destroyed"
  	redirect_to investors_path
  end

  private

    def correct_user
      @investor = Investor.find(params[:id])
      redirect_to root_path unless current_user.investor == @investor || current_user.global_admin?
    end
end