class Investor < ActiveRecord::Base
  attr_accessible :name
  has_many :users

  validates :name, presence: true
  has_many :relationships, dependent: :destroy
  has_many :funds, through: :relationships

end
