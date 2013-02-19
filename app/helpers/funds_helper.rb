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

	def up_capture(fund, index)
		# find months of a benchmark where the fund_returns are positive.
		# get the months in an array.  get those same months for the respective fund.
		@start_end = start_end_dates(fund)

		@ind_returns = Month.where(fund_id: index.id, mend: @start_end[0]..@start_end[1]).where("fund_return > ?", 0).pluck(:fund_return).map{|n| n/100.0}
		@mends = Month.where(fund_id: index.id).where("fund_return > ?", 0).pluck(:mend)

		@fund_returns = Month.where(fund_id: fund.id, mend: @mends).pluck(:fund_return).map{|n| n / 100.0}

		return calc_ann_return(@fund_returns)/calc_ann_return(@ind_returns)
	end

	def down_capture(fund, index)
		@start_end = start_end_dates(fund)

		@ind_returns = Month.where(fund_id: index.id, mend: @start_end[0]..@start_end[1]).where("fund_return < ?", 0).pluck(:fund_return).map{|n| n/100.0}
		@mends = Month.where(fund_id: index.id).where("fund_return < ?", 0).pluck(:mend)

		@fund_returns = Month.where(fund_id: fund.id, mend: @mends).pluck(:fund_return).map{|n| n / 100.0}

		return calc_ann_return(@fund_returns)/calc_ann_return(@ind_returns)
	end

	def ann_return_by_date(fund, start_date = nil, end_date = nil)
		calc_ann_return(get_returns(fund, start_date, end_date))
	end

	def get_returns(fund, start_date = nil, end_date = nil)
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

	def calc_ann_return(months = [])
		# if less than 12 months, produce the return non-annualized

		#make sure the number format is correct
		if months.count < 12
			(months.map{|n| n + 1}.inject{|product, x| product*x} - 1)*1.0
		else
			(((months.map{|n| n + 1}.inject{|product, x| product*x})**(12.0/(months.count*1.0) )) - 1)*1.0
		end
	end

	def months_array_sized_by_fund(fund_one, fund_two)
	end

	def variance(fund, start_date = nil, end_date = nil)
		# do not use for less than 12 months???????
		@returns = get_returns(fund, start_date, end_date)
		@average = @returns.inject{|sum, x| sum + x}/@returns.count
		@sum_of_diffs_squared = @returns.map{|n| ((n - @average)**2)}.inject{|sum,m| sum + m}
		@variance = (@sum_of_diffs_squared/(@returns.count - 1)) 
	end

	def st_dev(fund)
		@variance = variance(fund)
		@stdev = Math.sqrt(@variance)
		#not converted for percentages
	end

	def ann_st_dev(fund, start_date = nil, end_date = nil)
		@variance = variance(fund, start_date, end_date)
		@st_dev = Math.sqrt(@variance) * Math.sqrt(12.0)
	end

	def beta(fund, index, start_date = nil, end_date = nil)
		covariance(fund, index)/variance(index)
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

	def alpha(fund, index)
		@fund_returns = get_returns(fund)
		@index_returns = get_returns(index)

		(1 + (average(@fund_returns) - beta(fund, index) * average(@index_returns)))**12 - 1
	end

	def correlation(fund_one, fund_two)
		covariance(fund_one, fund_two) / (st_dev(fund_one) * st_dev(fund_two))
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