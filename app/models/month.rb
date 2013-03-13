class Month < ActiveRecord::Base
  attr_accessible :fund_id, :mend, :fund_return

  validates :mend, presence: true, uniqueness: { scope: :fund_id }
  validates :fund_id, presence: true
  validates :fund_return, presence: true

  default_scope order: 'months.mend'

  belongs_to :fund

  def self.import(file, fund_id)
  	CSV.foreach(file.path, headers: true) do |row|
      month = Month.find_by_mend_and_fund_id(Date.strptime(row["mend"],'%b-%y'), fund_id) || 
  			Month.new(mend: Date.strptime(row["mend"],'%b-%y'), fund_id: fund_id)
  		month.assign_attributes({fund_return: row["return"]})
  		month.save!
  	end
  end
end