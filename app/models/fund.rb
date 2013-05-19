class Fund < ActiveRecord::Base
  attr_accessible :name, :months_attributes, :fund_type, :bmark, :trackers_attributes, :retired
  validates :name, presence: true

  VALID_FUND_TYPES = ['Emerging Markets', 'Equity L/S', 
    'Equity L/S Sector', 'Equity Long', 'Equity Market Neutral', 
    'Event Driven', 'Global Macro', 'Managed Futures', 
    'Multi-Strategy',]

  validates :name, uniqueness: true
  validates_inclusion_of :retired, :in => [true,false]
  validates :fund_type,
  	inclusion: { :in => VALID_FUND_TYPES,
  	message: "%{value} is not a valid fund type" },
    presence: true

  has_many :months, dependent: :destroy
  has_many :relationships, dependent: :destroy
  has_many :investors, through: :relationships

  require 'matrix'
  #
  #
  #limit the number of trackers to two with a validation
  #
  #

  has_many :trackers, dependent: :destroy
  has_many :benchmarks, through: :trackers, dependent: :destroy

  accepts_nested_attributes_for :months, allow_destroy: true
  accepts_nested_attributes_for :trackers, allow_destroy: true
  
  def self.get_initial_benchmarks(fund)
    @benchmarks = []
    if fund.fund_type == 'Emerging Markets'
      @benchmarks[0] = Fund.find_by_name('CS Tremont - EM').id
      @benchmarks[1] = Fund.find_by_name('MSCI ACWI').id
    elsif fund.fund_type == 'Equity L/S'
      @benchmarks[0] = Fund.find_by_name('CS Tremont - Equity L/S').id
      @benchmarks[1] = Fund.find_by_name('S&P 500').id
    elsif fund.fund_type == 'Equity L/S Sector'
      @benchmarks[0] = Fund.find_by_name('CS Tremont - Equity L/S').id
      @benchmarks[1] = Fund.find_by_name('S&P 500').id
    elsif fund.fund_type == 'Equity Long'
      @benchmarks[0] = Fund.find_by_name('S&P 500').id
      @benchmarks[1] = Fund.find_by_name('MSCI ACWI').id
    elsif fund.fund_type == 'Equity Market Neutral'
      @benchmarks[0] = Fund.find_by_name('CS Tremont - Managed Futures').id
      @benchmarks[1] = Fund.find_by_name('S&P 500').id
    elsif fund.fund_type == 'Event Driven'
      @benchmarks[0] = Fund.find_by_name('CS Tremont - Event Driven').id
      @benchmarks[1] = Fund.find_by_name('MSCI ACWI').id
    elsif fund.fund_type == 'Global Macro'
      @benchmarks[0] = Fund.find_by_name('CS Tremont - Global Macro').id
      @benchmarks[1] = Fund.find_by_name('S&P 500').id
    elsif fund.fund_type == 'Managed Futures'
      @benchmarks[0] = Fund.find_by_name('CS Tremont - Managed Futures').id
      @benchmarks[1] = Fund.find_by_name('S&P 500').id
    elsif fund.fund_type == 'Multi-Strategy'
      @benchmarks[0] = Fund.find_by_name('CS Tremont - Multi-Strategy').id
      @benchmarks[1] = Fund.find_by_name('MSCI ACWI').id
    else
      @benchmarks[0] = Fund.find_by_name('S&P 500').id
      @benchmarks[1] = Fund.find_by_name('MSCI ACWI').id
    end
    return @benchmarks
  end

  def self.calc_ann_return(months = [])
    # if less than 12 months, produce the return non-annualized

    #make sure the number format is correct
    if months.count <= 12
      (months.map{|n| n + 1}.inject{|product, x| product*x} - 1)*1.0
    else
      (((months.map{|n| n + 1}.inject{|product, x| product*x})**(12.0/(months.count*1.0) )) - 1)*1.0
    end
  end

  def self.get_returns(fund, start_date = nil, end_date = nil)
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

    #what are the inputs and outputs for the loops below
    #input: @new_funds_array, @new_funds_dates.  uses calc_ann_return and get returns.
    #output: @all_funds_and_years.  each array of arrays has the annual performance for a fund.

    # get arrays for each fund with the yearly returns
    # use parent and child array structure again
    
  def self.all_funds_and_years(funds_array = [], dates_array = [])
    
    #setting the initial fund and date variables
    @new_funds_array = funds_array
    @new_fund_dates = dates_array

    @all_funds_and_years = []
    @all_years_for_fund = []

    @new_funds_array.each do |f|
      @perf_year = @new_fund_dates[1].year
      while ((@new_fund_dates[1].year - @perf_year) <= 9)
        if f == @fund && (@perf_year >= start_end_dates(f)[0].year)
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
        elsif f != @fund && (@perf_year >= start_end_dates(f)[0].year)
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

    return @all_funds_and_years
  end

  def self.years_header(recent_year)
    return [recent_year.year,
              recent_year.years_ago(1).year,
              recent_year.years_ago(2).year,
              recent_year.years_ago(3).year,
              recent_year.years_ago(4).year,
              recent_year.years_ago(5).year,
              recent_year.years_ago(6).year,
              recent_year.years_ago(7).year,
              recent_year.years_ago(8).year]
  end

  # performance comparison over different time periods
  # inputs: array_of_performance_dates, the_most_recent_month, start_end_dates for each fund, funds_array
  # uses:   calc_ann_return, get_returns
  # outputs: fund at the head of each array.  ann_return in other spots

  def self.perf_over_diff_periods(funds_array = [], recent_date)
    arr_with_returns= []
    child_arr = []
    dates_array = [recent_date,
                  recent_date.months_ago(2),
                  recent_date.months_ago(5),
                  recent_date.months_ago(11),
                  recent_date.months_ago(23),
                  recent_date.months_ago(35),
                  recent_date.months_ago(59),
                  recent_date.months_ago(83),
                  recent_date.months_ago(119)]

    funds_array.each do |f|
      fund_start_date = start_end_dates(f)[0]
      dates_array.each do |n|
        if fund_start_date <= n
          child_arr << calc_ann_return(get_returns(f,n,recent_date))
        end
      end
      arr_with_returns << child_arr.unshift(f)
      child_arr = [] #clear the child array for the next fund
    end
    return arr_with_returns
  end

  def self.start_end_dates(fund)
    first_and_last_date = []
    @months = fund.months
    first_and_last_date << @months.minimum(:mend)  #first date where there is data
    first_and_last_date << @months.maximum(:mend)  #last date where there is data

    return first_and_last_date
  end

  def self.monthly_returns(fund)
      @fund = fund
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

      return @parent_array
  end


  def self.correlation_table(funds = [], start_date, end_date)
    # input is an array of funds
    # get an array of months for each fund. store in an array
    # have 2 for loops running through the array calling correlation on each and saving it in a different array or arrays

    #array of each funds' months
    array_of_months = []
    
    funds.each do |f|
      array_of_months << get_returns(f, start_date, end_date)
    end
    
    child_array = []
    parent_array = []

    (0..(funds.count - 1)).each do |i|
      (0..(funds.count - 1)).each do |j|
        child_array[j] = correlation(array_of_months[i], array_of_months[j])
      end
      parent_array << child_array.unshift(funds[i])
      child_array = []
    end

    return parent_array
  end


  #have correlation take an array of months.
  #input the months into each of the subsequent methods


  def self.correlation(fund_one = [], fund_two = [])
    covariance(fund_one, fund_two) / (st_dev(fund_one) * st_dev(fund_two))
  end
  # use correlation, covariance, variance, stdev, get returns

  def self.covariance(fund_one = [], fund_two = [])
    @fund_one = fund_one
    @fund_two = fund_two

    @one_ave = average(@fund_one)
    @two_ave = average(@fund_two)

    @one_diff = @fund_one.map{|n| n - @one_ave}
    @two_diff = @fund_two.map{|n| n - @two_ave}

    @one_vec = Matrix.row_vector(@one_diff)
    @two_vec = Matrix.column_vector(@two_diff)

    @final = (@one_vec * @two_vec) / (@one_vec.count*1.0)

    return @final.to_a[0][0]
  end

  def self.variance(fund = [])
    # do not use for less than 12 months???????
    @returns = fund
    @average = @returns.inject{|sum, x| sum + x}/@returns.count
    @sum_of_diffs_squared = @returns.map{|n| ((n - @average)**2)}.inject{|sum,m| sum + m}
    @variance = (@sum_of_diffs_squared/(@returns.count))
  end

  def self.st_dev(fund = [])
    @variance = variance(fund)
    @stdev = Math.sqrt(@variance)
    #not converted for percentages
  end

  def self.average(months = [])
    months.inject{|sum, n| sum + n}/months.count
  end














end