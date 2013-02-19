class Tracker < ActiveRecord::Base
  attr_accessible :benchmark_id, :fund_id

  belongs_to :fund, class_name: "Fund"
  belongs_to :benchmark, class_name: "Fund"

  validates :fund_id, presence: true
  validates :benchmark_id, presence: true
end
