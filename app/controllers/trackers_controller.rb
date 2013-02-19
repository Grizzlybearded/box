class TrackersController < ApplicationController
before_filter :authorize_user
before_filter :authorize_ga

	def create
		@fund = Fund.find_by_id(params[:fund_id])
		@benchmark = Fund.find_by_name(params[:name])

		if @fund.trackers.build(benchmark_id: @benchmark.id).save
			flash[:success] = "New benchmark added!"
			redirect_to @fund
		else
			flash[:notice] = "Benchmark not added.  Error occurred."
			redirect_to root_url
		end
	end

	def destroy
		Tracker.find(params[:id]).destroy
		flash[:success] = "Benchmark removed from fund."
		redirect_to :back
	end

end
