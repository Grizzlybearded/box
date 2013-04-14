class FundsController < ApplicationController
before_filter :authorize_user
before_filter :correct_investor, except: [:show, :recent_returns, :highwater_mark, :index, :new, :create]
before_filter :correct_investor_for_show, only: [:show]

#this before filter is redundant
#before_filter :is_core_bmark, only: [:edit, :update, :destroy, :months_edit_for]

	def new
		@fund = Fund.new
	end

	def create

		#
		#
		#core_bmark is not included in the fund's params. look into this.
		#
		#

		@fund = Fund.new(params[:fund])
		if @fund.save
			@fund_benchmarks = Fund.get_initial_benchmarks(@fund)
			@fund.trackers.build(benchmark_id: @fund_benchmarks[0], user_id: nil).save
			@fund.trackers.build(benchmark_id: @fund_benchmarks[1], user_id: nil).save
			current_user.investor.relationships.build(fund_id: @fund.id).save
			flash[:success] = "New fund created"
			redirect_to new_import_return_path
		else
			render 'new'
		end
	end

	def index
		@funds = current_user.investor.funds.where(bmark: false).order("fund_type")
		@indices = current_user.investor.funds.where(bmark: true).order("name")
	end

	def show
		@fund = Fund.find(params[:id])
		@fund_dates = start_end_dates(@fund)

		#create benchmarks with user_id if not already done
		if !@fund.trackers.where(user_id: current_user.id).present?
			@benchmark_ids = @fund.trackers.where(user_id: nil).pluck(:benchmark_id)
			@benchmark_ids.each do |b|
				Tracker.new(fund_id: @fund.id, benchmark_id: b, user_id: current_user.id).save
			end
		end

		#get benchmarks with the user id
		@benchmark_ids_for_funds_array = @fund.trackers.where(user_id: current_user.id).pluck(:benchmark_id)
		@fund_bmark_false = Fund.where(id: @benchmark_ids_for_funds_array, bmark: false).order("name")
		@fund_bmark_true = Fund.where(id: @benchmark_ids_for_funds_array, bmark: true).order("name")
		@funds_array = (@fund_bmark_false + @fund_bmark_true).unshift(@fund)

		#NEED TO INSTANTIATE FUNDS_ARRAY BEFORE HERE

		if @fund_dates[0].present?

			#adjust the funds array to eliminate funds that have less than 3 dates or that don't have overlapping dates
			@new_funds_array = adjust_funds_array(@funds_array)

			#get the max/min dates from this array
			@max_fund_dates = adjust_to_same_dates(@new_funds_array)

			#this is the actual set of dates that are going to be pushed from params and used throughout the controller
			@new_fund_dates = adjust_dates_from_params(@max_fund_dates, params[:first_date], params[:last_date])

			# this has to be set here, in the controller, because it doesn't refresh in the view
			@max_date_for_datepicker = '-' + date_month_diff(adjust_to_same_dates(@new_funds_array)[1], Date.today.at_beginning_of_month).to_s + 'm' 
			@min_date_for_datepicker = '-' + date_month_diff(adjust_to_same_dates(@new_funds_array)[0], Date.today.at_beginning_of_month).to_s + 'm'

			#year range for datepicker
			@first_date_for_year_range = adjust_to_same_dates(@new_funds_array)[0]
			@last_date_for_year_range  = adjust_to_same_dates(@new_funds_array)[1]
			@year_range = @first_date_for_year_range.year.to_s + ":" + @last_date_for_year_range.year.to_s
			# year range wasn't working + years_diff(@max_fund_dates[0], Date.today).to_s + ":-" + years_diff(@max_fund_dates[1], Date.today).to_s

			#get fund names for graph labels
			@new_fund_names = @new_funds_array.map{|n| n.name}
			@removed_funds = @funds_array - @new_funds_array

			# THIS WILL NEED TO BE CHANGED WHEN THE INVESTOR SETTINGS ARE CHANGED
			@arr_for_benchmark_autocomplete = @current_user.investor.funds.pluck(:name) - @funds_array.map{|f| f.name}

			# FIX THE CHART SO IT CAN HAVE VARIABLE INPUTS
			@ykeys_for_chart = []
			@chart_arr = hash_arr_cumulative_for_many_benchmarks(@new_funds_array,@new_fund_dates[0], @new_fund_dates[1])
			for i in 0..(@new_funds_array.count - 1 )
				@ykeys_for_chart[i] = "fund_#{i}"
			end

			# header for table and below that, months in the past to calculate returns for that table
			@perf_header = ["1m", "3m", "6m", "1yr", "2yr", "3yr", "5yr", "7yr", "10yr"]
			@perf_over_diff_periods = Fund.perf_over_diff_periods(@new_funds_array,@new_fund_dates[1])
			
			@years_header = Fund.years_header(@new_fund_dates[1])
			@all_funds_and_years = Fund.all_funds_and_years(@new_funds_array, @new_fund_dates)

			# the monthly returns for a fund.  
			@parent_array = Fund.monthly_returns(@fund)
			
		end 		
	end

	def edit
		@fund = Fund.find(params[:id])
		@trackers = Tracker.where(fund_id: @fund.id, user_id: nil)
		@benchmarks_for_select = current_user.investor.funds.where(bmark:true)
	end

	def update
		@fund = Fund.find(params[:id])
		if @fund.core_bmark == false
			if @fund.update_attributes(params[:fund])
				flash[:success] = "Fund updated"
				redirect_to funds_path
			else
				render 'edit'
			end
		elsif @fund.core_bmark? && current_user.global_admin?
			if @fund.update_attributes(params[:fund])
				flash[:success] = "Fund updated"
				redirect_to funds_path
			else
				render 'edit'
			end
		else
			flash[:notice] = "This benchmark cannot be edited"
			redirect_to funds_path
		end
	end

	def months_edit_for
		@fund = Fund.find(params[:id])
		@months = @fund.months
		@month = @fund.months.build
	end

	def destroy
		@fund = Fund.find(params[:id])
		if @fund.core_bmark == false
			@fund.destroy
			flash[:success] = "Fund deleted"
			redirect_to funds_path
		elsif @fund.core_bmark? && current_user.global_admin?
			@fund.destroy
			flash[:success] = "Fund deleted"
			redirect_to funds_path
		else
			flash[:notice] = "This benchmark cannot be deleted"
			redirect_to funds_path
		end
	end

	def highwater_mark
		@funds_array = current_user.investor.funds.where(bmark: false).order("name")
	end

	def recent_returns
		@funds_array = current_user.investor.funds.where(bmark: false)
		@fund_ids = @funds_array.map {|n| n.id}

		@recent_date = Month.where(fund_id: @fund_ids).maximum(:mend)

		#store the funds that have the max date
		@funds_with_date = Month.where(mend: @recent_date, fund_id: @fund_ids).map{|n| n.fund}.sort {|a,b| a.name <=> b.name}

		#if (@funds_with_date.count / (@funds_array.count * 1.0)) <= 0.5
		#	@recent_date = @recent_date.months_ago(1)
		#	@funds_with_date = Month.where(mend: @recent_date, fund_id: @fund_ids).map{|n| n.fund}
		#end
		
		@removed_funds = @funds_array - @funds_with_date
	end

	private
		def correct_investor_for_show
			@fund = Fund.find(params[:id])
			redirect_to root_path unless current_user.investor.funds.include?(@fund) || current_user.global_admin?			
		end

		def correct_investor
			@fund = Fund.find(params[:id])
			redirect_to root_path unless current_user.investor.funds.where(core_bmark: false).include?(@fund) || current_user.global_admin?
		end

		#def is_core_bmark
		#	@fund = Fund.find(params[:id])
		#	redirect_to root_path unless !@fund.core_bmark? || current_user.global_admin?
		#end

	#DONE restrict edit/destroy of funds with core_bmark == true to global admin in controller and view
	#DONE create relationships for each core_bmark when investor is created.
	#for trackers, only allow indices that you are subscribed to be in the comparison array. user.investor.funds.where(bmark: true)
end