class Fund < ActiveRecord::Base
  attr_accessible :name, :months_attributes
  validates :name, presence: true
  default_scope order: 'LOWER(funds.name)'

  has_many :months, dependent: :destroy
  has_many :relationships, dependent: :destroy
  has_many :investors, through: :relationships

  has_many :trackers, dependent: :destroy
  has_many :benchmarks, through: :trackers

  accepts_nested_attributes_for :months, allow_destroy: true

end