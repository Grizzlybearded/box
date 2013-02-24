class Month < ActiveRecord::Base
  attr_accessible :aum, :fund_id, :gross, :mend, :net, :fund_return

  validates :mend, presence: true, uniqueness: { scope: :fund_id }
  validates :fund_id, presence: true
  #validates :gross, precision: 4, scale: 2
  #validates :net, precision: 4, scale: 2

  default_scope order: 'months.mend'

  belongs_to :fund

  def self.import(file)
  	CSV.foreach(file.path, headers: true) do |row|
  		month = Month.find_by_mend_and_fund_id(Date.strptime(row["mend"],'%b-%y'), row["fund id"]) || 
  			Month.new(mend: Date.strptime(row["mend"],'%b-%y'), fund_id: row["fund id"])
  		month.assign_attributes({gross: row["gross"], net: row["net"], aum: row["aum"], fund_return: row["return"]})
  		month.save!
  	end
  end
end