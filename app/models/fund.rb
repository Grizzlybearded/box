class Fund < ActiveRecord::Base
  attr_accessible :name, :months_attributes, :fund_type, :bmark, :trackers_attributes
  validates :name, presence: true

  VALID_FUND_TYPES = ['Emerging Markets', 'Equity L/S', 
    'Equity L/S Sector', 'Equity Long', 'Equity Market Neutral', 
    'Event Driven', 'Global Macro', 'Managed Futures', 
    'Multi-Strategy',]

  validates :name, uniqueness: true

  validates :fund_type,
  	inclusion: { :in => VALID_FUND_TYPES,
  	message: "%{value} is not a valid fund type" },
    presence: true

  has_many :months, dependent: :destroy
  has_many :relationships, dependent: :destroy
  has_many :investors, through: :relationships

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
end