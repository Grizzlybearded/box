class TrackersController < ApplicationController
before_filter :authorize_user
before_filter :is_investor, only: [:create]
before_filter :is_current_benchmark, only: [:destroy]

	def create
		@fund = Fund.find_by_id(params[:fund_id])
		@benchmark = Fund.find_by_name(params[:benchmark_name])

		#check for benchmark to itself - make that generate an error
		#make funds that are already in use not show up in the array.  do the same for the fund itself (don't let it show up)

		#check whether index
		#if index, push destroy tracker with with index and user_id == current_user.id
		#else, if benchmarks < 4, create regularly, else, destroy the one created_at first and then create
		if @benchmark.present? && @benchmark.bmark?
			#destroy the last one
			@benchmark_ids_array = @fund.benchmarks.where(bmark: true).pluck(:benchmark_id)
			Tracker.where(fund_id: @fund.id, benchmark_id: @benchmark_ids_array, user_id: current_user.id).last.destroy

			if @fund.trackers.build(benchmark_id: @benchmark.id, user_id: current_user.id).save
				flash[:success] = "New benchmark added!  Removed old benchmark."
				redirect_to @fund
			else
				flash[:notice] = "Benchmark not added.  Error occurred."
				redirect_to root_url
			end
		elsif @benchmark.present?
			if @fund.benchmarks.where(bmark: false).count < 3
				if @fund.trackers.build(benchmark_id: @benchmark.id, user_id: current_user.id).save
					flash[:success] = "New benchmark added!"
					redirect_to @fund
				else
					flash[:notice] = "Benchmark not added.  Error occurred."
					redirect_to @fund
				end
			else
				@benchmark_ids_array = @fund.benchmarks.where(bmark: false).pluck(:benchmark_id)
				Tracker.where(fund_id: @fund.id, benchmark_id: @benchmark_ids_array, user_id: current_user.id).last.destroy

				if @fund.trackers.build(benchmark_id: @benchmark.id, user_id: current_user.id).save
					flash[:success] = "New benchmark added! Removed old benchmark."
					redirect_to @fund
				else
					flash[:notice] = "Benchmark not added.  Error occurred."
					redirect_to @fund
				end
			end
		else
			flash[:notice] = "Benchmark not added.  Please try again."
			redirect_to @fund
		end
	end

	def destroy
		@tracker = Tracker.find(params[:id]) #this is the tracker record
		@fund = Fund.find_by_id(@tracker.benchmark_id) #this is the benchmark == fund.  this is done to check whether the fund is an admin
		@parent_fund = Fund.find_by_id(@tracker.fund_id) #this is so the parent_fund can build 

		#locals that are specific for this page
		id_to_array = [@tracker.benchmark_id]
		@default_trackers = @parent_fund.trackers.where(user_id: nil).limit(2).pluck(:benchmark_id) #ids of default
		@non_default_trackers = @parent_fund.trackers.where(user_id: current_user.id).pluck(:benchmark_id) #ids of benchmark
		

		if @fund.bmark?
			#both non default
			if (@default_trackers - @non_default_trackers).count == 2
				@tracker.destroy
				@parent_fund.trackers.build(benchmark_id: @default_trackers[0], user_id: current_user.id).save
				flash[:success] = "Benchmark replaced with default."
				redirect_to :back
			elsif (@default_trackers - @non_default_trackers).count == 0
			#both are default - don't do anything - user won't be able to destroy from the show view.
				flash[:notice] = "This is a default fund.  Change it from the Fund Edit page."
				redirect_to :back
			elsif (@default_trackers - @non_default_trackers).count == 1
				if (id_to_array - @default_trackers).count != 0 #this is not a default fund
					@tracker.destroy
					local = @default_trackers - @non_default_trackers
					@parent_fund.trackers.build(benchmark_id: local[0], user_id: current_user.id).save
					flash[:success] = "Benchmark replaced with default."
					redirect_to :back
				else #this is a default fund
					flash[:notice] = "This is a default fund.  Change it from the Fund Edit page."
					redirect_to :back	
				end
			else
				flash[:notice] = "Something is wrong with the code"
				redirect_to :back
			end
		else
			@tracker.destroy
			flash[:success] = "Benchmark removed from fund."
			redirect_to :back
		end
	end

	private
		def is_investor
			@fund = Fund.find_by_name(params[:benchmark_name])
			if @fund.present?
				redirect_to root_path unless current_user.investor.funds.include?(@fund) || @fund.bmark? || current_user.global_admin?
			else
				flash[:notice] = "That fund doesn't exist"
				redirect_to :back
			end
		end

		def is_current_benchmark
			@tracker = Tracker.find(params[:id])
			redirect_to root_path unless @tracker.user_id == current_user.id || current_user.global_admin?
		end
end