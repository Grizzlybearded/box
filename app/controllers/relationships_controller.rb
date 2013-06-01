class RelationshipsController < ApplicationController
before_filter :authorize_user
before_filter :authorize_ga, only: [:create]
before_filter :destroyable_if_starter, only: [:destroy]


	def create
		@fund = Fund.find_by_id(params[:fund_id])
		@investor = Investor.find_by_name(params[:name])
		if @fund.relationships.build(investor_id: @investor.id).save
			flash[:success] = "New investor added!"
			redirect_to @fund
		else
			flash[:notice] = "Investor not added.  Perhaps there isn't an investor by that name."
			redirect_to root_url
		end
	end

	def destroy
		Relationship.find(params[:id]).destroy
		flash[:success] = "Investor removed from fund."
		redirect_to :back
	end

	private

	def destroyable_if_starter
		relationship = Relationship.find(params[:id])
		fund = Fund.find_by_id(relationship.fund_id)
		if current_user.investor.funds.include?(fund)
			redirect_to :back unless fund.starter_fund == true || current_user.global_admin?
		else
			flash[:notice] = "You are not invested in this fund."
			redirect_to :back
		end
	end
end