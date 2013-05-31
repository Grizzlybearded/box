class RelationshipsController < ApplicationController
before_filter :authorize_user
before_filter :authorize_ga

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
end