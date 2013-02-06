class FundsController < ApplicationController
before_filter :authorize_user
before_filter :authorize_ga, except: [:show]

	def new
		@fund = Fund.new
	end

	def create
		@fund = Fund.new(params[:fund])
		if @fund.save
			flash[:success] = "New fund created"
			redirect_to @fund
		else
			render 'new'
		end
	end

	def index
		@funds = Fund.all
	end

	def show
		@fund = Fund.find(params[:id])
		@month = @fund.months.build
	end

	def edit
		@fund = Fund.find(params[:id])
	end

	def update
		@fund = Fund.find(params[:id])
		if @fund.update_attributes(params[:fund])
			flash[:success] = "Fund updated"
			redirect_to funds_path
		else
			render 'edit'
		end
	end

	def destroy
		Fund.find(params[:id]).destroy
		flash[:success] = "Fund destroyed"
		redirect_to funds_path
	end

end