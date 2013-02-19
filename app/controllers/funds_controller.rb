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

		@funds_array = @fund.benchmarks.unshift(@fund)

		if params[:show_var].present?
			@show_var = params[:show_var]
		else
			@show_var = "aum"
		end

		@perf_header = 		["1m", "3m", "6m", "1yr", "2yr", "3yr", "5yr", "7yr", "10yr"]
		@perf_months_ago = 	[@fund_dates[1],
								@fund_dates[1].months_ago(2),
								@fund_dates[1].months_ago(5),
								@fund_dates[1].months_ago(11),
								@fund_dates[1].months_ago(23),
								@fund_dates[1].months_ago(35),
								@fund_dates[1].months_ago(59),
								@fund_dates[1].months_ago(83),
								@fund_dates[1].months_ago(119)]

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

end