module FundsHelper
	require 'matrix'

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
			(months.map{|n| n + 1}.inject{|product, x| product*x} - 1)*100
		else
			(((months.map{|n| n + 1}.inject{|product, x| product*x})**(12.0/months.count)) - 1)*100
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

	def ann_st_dev(fund, start_date = nil, end_date = nil)
		@variance = variance(fund, start_date, end_date)
		@st_dev = Math.sqrt(@variance) * Math.sqrt(12.0) * 100
	end

	def beta(fund, index, start_date = nil, end_date = nil)
		covariance(fund, index)/variance(index) * 100
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
	end

	def correlation(fund_one, fund_two)
	end

	def upcapture
	end

	def start_end_dates(fund)
		first_and_last_date = []
		@months = fund.months
		first_and_last_date << @months.first.mend
		first_and_last_date << @months.last.mend
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

	def array_for_max_drawdown_for_graph
	end

	def max_drawdown(fund, start_date = nil, end_date = nil)
		@cum_returns = array_of_cumulative_return(fund, start_date, end_date)
		@highest_point = highwater_array(@cum_returns)
		return (@cum_returns.zip(@highest_point).map{|i,j| i/j - 1}.min)*100.0
	end

	def months_in_max_drawdown(fund)
	end

	def current_drawdown(fund, start_date = nil, end_date = nil)
		@cum_returns = array_of_cumulative_return(fund, start_date, end_date)
		@highest_point = highwater_array(@cum_returns)
		return ((@cum_returns.last/@highest_point.last) - 1)*100.0
	end

	def months_in_current_drawdown(fund)
	end

end