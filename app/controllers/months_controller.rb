class MonthsController < ApplicationController
before_filter :authorize_user, except: [:current_month]
before_filter :authorize_ga, except: [:current_month, :current_month_rates]

	def create
		@month = Month.new(params[:month])
		if @month.save
			flash[:success] = "New month added"
			redirect_to @month.fund
		else
			redirect_to :back
		end
	end

	def edit
		@month = Month.find(params[:id])
	end

	def update
		@month = Month.find(params[:id])
		if @month.update_attributes(params[:month])
			flash[:success] = "Month updated"
			redirect_to @month.fund
		else
			render 'edit'
		end
	end

	def destroy
		Month.find(params[:id]).destroy
		flash[:success] = "Month record destroyed"
		redirect_to :back
	end

	def import
		Month.import(params[:file])
		redirect_to root_url, notice: "Fund data imported"
	end

end