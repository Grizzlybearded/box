class Tracker < ActiveRecord::Base
  attr_accessible :benchmark_id, :fund_id, :user_id
  attr_readonly :fund_id, :user_id

  #do some sort of validation on which trackers can be added?

  belongs_to :fund, class_name: "Fund"
  belongs_to :benchmark, class_name: "Fund"

  validates :fund_id, presence: true
  validates :benchmark_id, presence: true

  validates_uniqueness_of :benchmark_id, scope: [:fund_id, :user_id]

  default_scope order: 'trackers.created_at DESC'
end
