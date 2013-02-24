module FundsHelper
	require 'matrix'

	def months_in_current_drawdown(fund)
	end

	def array_for_max_drawdown_for_graph
	end

	def months_in_max_drawdown(fund)
	end

	def has_date?(fund, date)
		@date = Month.where(fund_id: fund.id, mend: date)
		return @date.present?
	end

	def up_capture(fund, index, start_date = nil, end_date = nil)

		if start_date.nil? || end_date.nil?
			@start_end = start_end_dates(fund)
		else
			@start_end = [start_date, end_date]
		end

		# find months of a benchmark where the fund_returns are positive.
		# get the months in an array.  get those same months for the respective fund.
		@start_end = start_end_dates(fund)

		@ind_returns = Month.where(fund_id: index.id, mend: @start_end[0]..@start_end[1]).where("fund_return > ?", 0).pluck(:fund_return).map{|n| n/100.0}
		@mends = Month.where(fund_id: index.id).where("fund_return > ?", 0).pluck(:mend)

		@fund_returns = Month.where(fund_id: fund.id, mend: @mends).pluck(:fund_return).map{|n| n / 100.0}

		return calc_ann_return(@fund_returns)/calc_ann_return(@ind_returns)
	end

	def down_capture(fund, index, start_date = nil, end_date = nil)
		
		if start_date.nil? || end_date.nil?
			@start_end = start_end_dates(fund)
		else
			@start_end = [start_date, end_date]
		end
		

		@ind_returns = Month.where(fund_id: index.id, mend: @start_end[0]..@start_end[1]).where("fund_return < ?", 0).pluck(:fund_return).map{|n| n/100.0}
		@mends = Month.where(fund_id: index.id).where("fund_return < ?", 0).pluck(:mend)

		@fund_returns = Month.where(fund_id: fund.id, mend: @mends).pluck(:fund_return).map{|n| n / 100.0}

		return calc_ann_return(@fund_returns)/calc_ann_return(@ind_returns)
	end

	def ann_return_by_date(fund, start_date = nil, end_date = nil)
		calc_ann_return(get_returns(fund, start_date, end_date))
	end

	def get_returns(fund, start_date = nil, end_date = nil)
		if !fund.nil?
			if start_date.present? and end_date.present?
				@months = Month.where(fund_id: fund.id, mend: start_date..end_date).pluck(:fund_return).map{|n| (n/100.0)}
			elsif start_date.present? and !end_date.present?
				@months = Month.where(fund_id: fund.id, mend: start_date..Month.where(fund_id: fund.id).maximum(:mend)).pluck(:fund_return).map{|n| (n/100.0)}
			elsif !start_date.present? and end_date.present?
				@months = Month.where(fund_id: fund.id, mend: Month.where(fund_id: fund.id).minimum(:mend)..end_date).pluck(:fund_return).map{|n| (n/100.0)}
			else
				@months = Month.where(fund_id: fund.id).pluck(:fund_return).map{|n| (n/100.0)}
			end
		end
	end

	def calc_ann_return(months = [])
		# if less than 12 months, produce the return non-annualized

		#make sure the number format is correct
		if months.count <= 12
			(months.map{|n| n + 1}.inject{|product, x| product*x} - 1)*1.0
		else
			(((months.map{|n| n + 1}.inject{|product, x| product*x})**(12.0/(months.count*1.0) )) - 1)*1.0
		end
	end

	def months_diff(fund_one, fund_two)
		@one_dates = start_end_dates(fund_one)
		@two_dates = start_end_dates(fund_two)
		@diff = (@one_dates[1].year - @two_dates[1].year)*12 + (@one_dates[1].month - @two_dates[1].month)
		return @diff
	end

	def adjust_to_same_dates(funds = [])
		@funds_array = funds
		@final_dates = start_end_dates(@funds_array[0])
		@funds_array.each do |f|
			@loc_dates = start_end_dates(f)
			if 	@loc_dates[0] > @final_dates[0]
				@final_dates[0] = @loc_dates[0]
			end
			if @loc_dates[1] < @final_dates[1]
				@final_dates[1] = @loc_dates[1]
			end
		end

		return @final_dates
	end

	def adjust_funds_array(funds = [], date_one, date_two)
		#spit out the correct funds array
		@funds_array = funds
		funds.each do |f|
			if f.months.where(mend: [date_one, date_two]).count == 0
				@funds_array.delete(f)
			end
		end
		return @funds_array
	end

	def variance(fund, start_date = nil, end_date = nil)
		# do not use for less than 12 months???????
		@returns = get_returns(fund, start_date, end_date)
		@average = @returns.inject{|sum, x| sum + x}/@returns.count
		@sum_of_diffs_squared = @returns.map{|n| ((n - @average)**2)}.inject{|sum,m| sum + m}
		@variance = (@sum_of_diffs_squared/(@returns.count - 1)) 
	end

	def st_dev(fund, start_date = nil, end_date = nil)
		@variance = variance(fund, start_date, end_date)
		@stdev = Math.sqrt(@variance)
		#not converted for percentages
	end

	def ann_st_dev(fund, start_date = nil, end_date = nil)
		@variance = variance(fund, start_date, end_date)
		@st_dev = Math.sqrt(@variance) * Math.sqrt(12.0)
	end

	def beta(fund, index, start_date = nil, end_date = nil)
		covariance(fund, index, start_date, end_date)/variance(index, start_date,end_date)
		#not converted for percentages
	end

	def average(months = [])
		months.inject{|sum, n| sum + n}/months.count
	end

	def covariance(fund_one, fund_two, start_date = nil, end_date = nil)
		@fund_one = get_returns(fund_one, start_date, end_date)
		@fund_two = get_returns(fund_two, start_date, end_date)

		@one_ave = average(@fund_one)
		@two_ave = average(@fund_two)

		@one_diff = @fund_one.map{|n| n - @one_ave}
		@two_diff = @fund_two.map{|n| n - @two_ave}

		@one_vec = Matrix.row_vector(@one_diff)
		@two_vec = Matrix.column_vector(@two_diff)

		@final = (@one_vec * @two_vec) / (@one_vec.count*1.0)

		return @final.to_a[0][0]
	end

	def alpha(fund, index, start_date = nil, end_date = nil)
		@fund_returns = get_returns(fund, start_date, end_date)
		@index_returns = get_returns(index, start_date, end_date)

		(1 + (average(@fund_returns) - beta(fund, index, start_date, end_date) * average(@index_returns)))**12 - 1
	end

	def correlation(fund_one, fund_two, start_date = nil, end_date = nil)
		covariance(fund_one, fund_two, start_date, end_date) / (st_dev(fund_one, start_date, end_date) * st_dev(fund_two, start_date, end_date))
	end

	def start_end_dates(fund)
		first_and_last_date = []
		@months = fund.months
		first_and_last_date << @months.minimum(:mend)  #first date where there is data
		first_and_last_date << @months.maximum(:mend)  #last date where there is data

		return first_and_last_date
	end

	def index_has_dates?(start_date = nil, end_date = nil, index)
	end

	def array_of_cumulative_return(fund, start_date = nil, end_date = nil)
		@returns = get_returns(fund, start_date, end_date)
		@cumulative_array = [1.0]
		
		# make array with hashes for graphing
		# ADD DATES TO THIS OR IT WON'T GRAPH
		
		for i in 0..(@returns.count - 1)
			@cumulative_array[i+1] = (@cumulative_array[i]*(@returns[i] + 1.0))
		end
		return @cumulative_array
	end

	def hash_arr_cumulative_ret(fund_one, fund_two = nil, fund_three = nil, start_date = nil, end_date = nil)
		@r_one = get_returns(fund_one, start_date, end_date)
		@c_one = [1.00]
		
		@r_two = get_returns(fund_two, start_date, end_date)
		@c_two = [1.00]

		@r_three = get_returns(fund_three, start_date, end_date)
		@c_three = [1.00]
		# make array with hashes for graphing
		# ADD DATES TO THIS OR IT WON'T GRAPH
		@final_arr = []

		if fund_one.present? && start_date.present? && end_date.present?
			for i in 0..(@r_one.count - 1)
				@c_one[i+1] = (@c_one[i]*(@r_one[i] + 1))
				if fund_two.present? && fund_two.months.where(mend: start_date).present? && fund_two.months.where(mend: end_date).present?
					@c_two[i+1] = (@c_two[i]*(@r_two[i] + 1))
				end
				if fund_three.present? && fund_three.months.where(mend: start_date).present? && fund_three.months.where(mend: end_date).present?
					@c_three[i+1] = (@c_three[i]*(@r_three[i] + 1))
				end
			end

			#get the row from each array and put it in the hash if it exists

			for i in 0..(@c_one.count - 1)
				@final_arr[i] = {date: start_date.months_since(i-1), fund_one: ((@c_one[i]*100.0).floor/100.0)}
				if fund_two.present? && fund_two.months.where(mend: start_date).present? && fund_two.months.where(mend: end_date).present?
					@final_arr[i].merge!({fund_two: (@c_two[i]*100.0).floor/100.0 }) 
				end
				if fund_three.present? && fund_three.months.where(mend: start_date).present? && fund_three.months.where(mend: end_date).present?
					@final_arr[i].merge!({fund_three: (@c_three[i]*100.0).floor/100.0 })
				end
			end
		end

		return @final_arr
	end

	def highwater_date(fund)
		@returns = array_of_cumulative_return(fund)
		@index = @returns.each_with_index.max[1] - 1
		
		return fund.months[@index].mend
	end

	def highwater_array(fund = [])
		#returns an array of the highest point of the fund at a given time
		@highest_point = [1]
		for i in 1..(fund.count-1)
			if fund[i] > @highest_point[i-1]
				@highest_point[i] = fund[i]
			else
				@highest_point[i] = @highest_point[i-1]
			end
		end
		return @highest_point
	end

	def max_drawdown(fund, start_date = nil, end_date = nil)
		@cum_returns = array_of_cumulative_return(fund, start_date, end_date)
		@highest_point = highwater_array(@cum_returns)
		return (@cum_returns.zip(@highest_point).map{|i,j| i/j - 1}.min)*100.0
	end

	def current_drawdown(fund, start_date = nil, end_date = nil)
		@cum_returns = array_of_cumulative_return(fund, start_date, end_date)
		@highest_point = highwater_array(@cum_returns)
		return ((@cum_returns.last/@highest_point.last) - 1)*100.0
	end

end