class MonthsController < ApplicationController
before_filter :authorize_user
#before_filter :authorize_ga, only: [:import]
before_filter :correct_investor, except: [:create, :import]

	def create
		@month = Month.new(params[:month])
		if current_user.investor.funds.where(core_bmark: false).pluck(:fund_id).include?(@month.fund_id)
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

	#make is so that the user can't import unless he is an owner of the fund.
	def import
		@fund = Fund.find_by_id(params[:fund_id])
		if current_user.investor.funds.where(core_bmark: false).include?(@fund)
			Month.import(params[:file], @fund.id)
			UserMailer.fund_data_imported(current_user, @fund).deliver
			redirect_to root_url, notice: "Fund data imported"
		else
			flash[:notice] = "You may only import data for funds in which you are invested"
			redirect_to :back
		end
	end

	private
		def correct_investor
			@fund = Month.find(params[:id]).fund
			redirect_to root_path unless current_user.investor.funds.where(core_bmark: false).include?(@fund) || current_user.global_admin?
		end
end