class InvestorsController < ApplicationController
  before_filter :authorize_user
  before_filter :authorize_ga
  def new
  	@investor = Investor.new
  end

  def create
  	@investor = Investor.new(params[:investor])
  	if @investor.save
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
end