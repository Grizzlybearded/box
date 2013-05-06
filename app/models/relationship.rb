class Relationship < ActiveRecord::Base
  attr_accessible :fund_id, :investor_id
  validates :fund_id, presence: true, uniqueness: { scope: :investor_id }
  validates :investor_id, presence: true, uniqueness: { scope: :fund_id }

  attr_readonly :investor_id, :fund_id

  belongs_to :fund
  belongs_to :investor
end
