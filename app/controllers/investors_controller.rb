class InvestorsController < ApplicationController
  before_filter :authorize_user
  before_filter :authorize_ga, except: [:show]
  before_filter :correct_user, only: [:show]
  #the authorize_ga and correct_user before_filters work together to create the desired restrictions

  def new
  	@investor = Investor.new
  end

  def create
  	@investor = Investor.new(params[:investor])
  	if @investor.save
      
      #subscribe to all the core benchmarks
      Fund.where(core_bmark: true).each do |f|
        @investor.relationships.build(f.id).save
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