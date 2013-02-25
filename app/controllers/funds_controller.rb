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

		@fund_dates = start_end_dates(@fund)

		#only have 2 benchmarks in the show view
		@funds_array = @fund.benchmarks.limit(2).unshift(@fund)

		if @fund_dates[0].present?

			@new_funds_array = adjust_funds_array(@funds_array , @fund_dates[1], @fund_dates[1].months_ago(1))
			@new_fund_dates = adjust_to_same_dates(@new_funds_array)

			#get fund names for graph labels
			@new_fund_names = @funds_array.map{|n| n.name}
			@removed_funds = @funds_array - @new_funds_array

			@chart_arr = hash_arr_cumulative_ret(@funds_array[0],@funds_array[1] ? @funds_array[1] : nil, @funds_array[2] ? @funds_array[2] : nil, @new_fund_dates[0], @new_fund_dates[1])

			if params[:show_var].present?
				@show_var = params[:show_var]
			else
				@show_var = "aum"
			end

			@perf_header = 		["1m", "3m", "6m", "1yr", "2yr", "3yr", "5yr", "7yr", "10yr"]
			@perf_months_ago = 	[@new_fund_dates[1],
									@new_fund_dates[1].months_ago(2),
									@new_fund_dates[1].months_ago(5),
									@new_fund_dates[1].months_ago(11),
									@new_fund_dates[1].months_ago(23),
									@new_fund_dates[1].months_ago(35),
									@new_fund_dates[1].months_ago(59),
									@new_fund_dates[1].months_ago(83),
									@new_fund_dates[1].months_ago(119)]

			
			@years_header = [@new_fund_dates[1].year,
								@new_fund_dates[1].years_ago(1).year,
								@new_fund_dates[1].years_ago(2).year,
								@new_fund_dates[1].years_ago(3).year,
								@new_fund_dates[1].years_ago(4).year,
								@new_fund_dates[1].years_ago(5).year,
								@new_fund_dates[1].years_ago(6).year,
								@new_fund_dates[1].years_ago(7).year,
								@new_fund_dates[1].years_ago(8).year]

			# get arrays for each fund with the yearly returns
			# use parent and child array structure again
			@all_funds_and_years = []
			@all_years_for_fund = []
			
			@funds_array.each do |f|
				@perf_year = @new_fund_dates[1].year
				while ((@new_fund_dates[1].year - @perf_year) <= 9)
					

					#THIS DOESN'T CHECK FOR INDICES THAT HAVE RETURNS THAT START AFTER 9 YEARS AGO.  WILL GET A NIL ERROR IN CALC_ANN_RETURN WHEN THIS OCCUR


					if f == @fund && (@perf_year >= @new_fund_dates[0].year)
						if @perf_year == @new_fund_dates[1].year
							# checks during the chronological last year
							@all_years_for_fund << calc_ann_return(get_returns(f, Date.new(@perf_year,1,1),@new_fund_dates[1]))
							@all_years_for_fund.unshift(f)
						elsif @perf_year == @new_fund_dates[0].year
							# checks for the chronological first year
							@all_years_for_fund << calc_ann_return(get_returns(f, @new_fund_dates[0], Date.new(@perf_year,12,1)))
						else
							@all_years_for_fund << calc_ann_return(get_returns(f, Date.new(@perf_year,1,1), Date.new(@perf_year,12,1)))
						end
					elsif f != @fund
						if @perf_year == @new_fund_dates[1].year
							# checks during the chronological last year
							@all_years_for_fund << calc_ann_return(get_returns(f, Date.new(@perf_year,1,1),@new_fund_dates[1]))
							@all_years_for_fund.unshift(f)
						else
							@all_years_for_fund << calc_ann_return(get_returns(f, Date.new(@perf_year,1,1), Date.new(@perf_year,12,1)))
						end
					end
					#iterate
					@perf_year = @perf_year - 1
				end
				#store in the parent array unless the there are not values in the array
				if @all_years_for_fund.present?
					@all_funds_and_years << @all_years_for_fund
				end
				#clear child array
				@all_years_for_fund = []
			end

			#find the minimum and maximum dates/years.  store the diff+1 in a variable - loop until we are greater than the variable
			@parent_array = []
			@child_array = []
			@year = Month.where(fund_id: @fund.id).minimum(:mend).year
			while @year < (Month.where(fund_id: @fund.id).maximum(:mend).year + 1) do
				#create conditions for the mend to be pulled
				@local_months = {}

				Month.where(fund_id: @fund.id, mend: ( Date.new(@year,1,1)..Date.new(@year,12,1) ) ).each{|date| @local_months[date.mend] = date}

				#iterate through 1-12 for each month.  push into the child array
				for i in 1..12
					# if month of object == loop, then save in x, else x = nil
					if @local_months[Date.new(@year,i,1)].present?
						@child_array << @local_months[Date.new(@year,i,1)].fund_return
					else
						@child_array << nil
					end
				end
				@ytd = @child_array.reject{|n| n==nil}.map{|n| (n/100.0)+1}.inject{|product,x| product*x}
			
				if !@ytd.nil?
					@ytd = (@ytd - 1)*100.0
				end
			
				#store the ytd value in the child_array
				@child_array<< @ytd
			
				#put the year in the front of the array
				@child_array.unshift(@year)
			
				#store the child_array in the parent_array and reset for the next loop
				@parent_array << @child_array
				@child_array = []
				@year += 1
			end
		end 		
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

	def show_for_admin
		@fund = Fund.find(params[:id])
	end

	def destroy
		Fund.find(params[:id]).destroy
		flash[:success] = "Fund destroyed"
		redirect_to funds_path
	end

	def highwater_mark
		@funds_array = current_user.investor.funds
	end

	def recent_returns
		@recent_date = Month.maximum(:mend)
		@funds_array = current_user.investor.funds

		@fund_ids = @funds_array.map{|n| n.id}

		#store the funds that have the max date
		@funds_with_date = Month.where(mend: @recent_date, fund_id: @fund_ids).map{|n| n.fund}

		while ( (@funds_with_date.count / (@funds_array.count * 1.0)) < 0.6 )
			@recent_date = @recent_date.months_ago(1)
			@funds_with_date = Month.where(mend: @recent_date, fund_id: @fund_ids).map{|n| n.fund}
		end
		
		@removed_funds = @funds_array - @funds_with_date
	end
end