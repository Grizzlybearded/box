class MonthsController < ApplicationController
before_filter :authorize_user
before_filter :correct_investor, except: [:create, :import]

	def create
		@month = Month.new(params[:month])
		if current_user.investor.funds.where(bmark: false).pluck(:fund_id).include?(@month.fund_id)
			if @month.save
				flash[:success] = "New month added"
				redirect_to months_edit_for_fund_path(@month.fund)
			else
				flash[:notice] = "Return not added"
				redirect_to :back
			end
		else
			flash[:notice] = "You may only add data to funds for which you are an investor"
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
			redirect_to months_edit_for_fund_path(@month.fund)
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

	private
		def correct_investor
			@fund_id = Month.find(params[:id]).fund_id
			redirect_to root_path unless current_user.investor.funds.where(bmark: false).pluck(:fund_id).include?(@fund_id) || current_user.global_admin?
		end
end