class Month < ActiveRecord::Base
  attr_accessible :fund_id, :mend, :fund_return

  validates :mend, presence: true, uniqueness: { scope: :fund_id }
  validates :fund_id, presence: true
  validates :fund_return, presence: true

  default_scope order: 'months.mend'

  belongs_to :fund

  def self.import(file)
  	CSV.foreach(file.path, headers: true) do |row|
    	#if current_user.investor.funds.where(bmark: false).pluck(:id).include?(row["fund id"])
        month = Month.find_by_mend_and_fund_id(Date.strptime(row["mend"],'%b-%y'), row["fund id"]) || 
    			Month.new(mend: Date.strptime(row["mend"],'%b-%y'), fund_id: row["fund id"])
    		month.assign_attributes({fund_return: row["return"]})
    		month.save!
      #end
  	end
  end
end