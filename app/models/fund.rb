class Fund < ActiveRecord::Base
  attr_accessible :name, :months_attributes, :fund_type, :bmark
  validates :name, presence: true

  VALID_FUND_TYPES = ['Emerging Markets', 'Equity L/S', 'Equity L/S Sector', 'Equity Long', 'Equity Market Neutral', 'Event Driven', 'Global Macro', 'Managed Futures', 'Multi-Strategy',] 
  validates :fund_type,
  	inclusion: { :in => VALID_FUND_TYPES,
  	message: "%{value} is not a valid fund type" },
    presence: true

  has_many :months, dependent: :destroy
  has_many :relationships, dependent: :destroy
  has_many :investors, through: :relationships

  has_many :trackers, dependent: :destroy
  has_many :benchmarks, through: :trackers, dependent: :destroy

  accepts_nested_attributes_for :months, allow_destroy: true

end