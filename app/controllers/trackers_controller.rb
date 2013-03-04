class TrackersController < ApplicationController
before_filter :authorize_user
before_filter :authorize_ga

	def create
		@fund = Fund.find_by_id(params[:fund_id])
		@benchmark = Fund.find_by_name(params[:benchmark_name])

		#check for benchmark to itself - make that generate an error
		#make funds that are already in use not show up in the array.  do the same for the fund itself (don't let it show up)

		#check whether index
		#if index, push destroy tracker with with index and user_id == current_user.id
		#else, if benchmarks < 4, create regularly, else, destroy the one created_at firstand then create
		if @benchmark.bmark?
			#destroy the last one
			@benchmark_ids_array = @fund.benchmarks.where(bmark: true).pluck(:benchmark_id)
			Tracker.where(fund_id: @fund.id, benchmark_id: @benchmark_ids_array, user_id: current_user.id).last.destroy

			if @fund.trackers.build(benchmark_id: @benchmark.id, user_id: current_user.id).save
				flash[:success] = "New benchmark added!"
				redirect_to @fund
			else
				flash[:notice] = "Benchmark not added.  Error occurred."
				redirect_to root_url
			end
		else
			if @fund.benchmarks.where(bmark: false).count < 3
				if @fund.trackers.build(benchmark_id: @benchmark.id, user_id: current_user.id).save
					flash[:success] = "New benchmark added!"
					redirect_to @fund
				else
					flash[:notice] = "Benchmark not added.  Error occurred."
					redirect_to root_url
				end
			else
				@benchmark_ids_array = @fund.benchmarks.where(bmark: false).pluck(:benchmark_id)
				Tracker.where(fund_id: @fund.id, benchmark_id: @benchmark_ids_array, user_id: current_user.id).last.destroy

				if @fund.trackers.build(benchmark_id: @benchmark.id, user_id: current_user.id).save
					flash[:success] = "New benchmark added!"
					redirect_to @fund
				else
					flash[:notice] = "Benchmark not added.  Error occurred."
					redirect_to root_url
				end				
			end
		end
	end

	def destroy
		Tracker.find(params[:id]).destroy
		flash[:success] = "Benchmark removed from fund."
		redirect_to :back
	end
end