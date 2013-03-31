class Month < ActiveRecord::Base
  attr_accessible :fund_id, :mend, :fund_return

  validates :mend, presence: true, uniqueness: { scope: :fund_id }
  validates :fund_id, presence: {message: "name: check that the name exists and is correct."}
  validates :fund_return, presence: true
  validates :fund, presence: {message: "name: check spelling please. All words are case sensitive."}

  default_scope order: 'months.mend'

  belongs_to :fund

=begin
  def self.import(file, fund_id)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      month = Month.find_by_mend_and_fund_id(row["mend"], fund_id) || 
  			Month.new(mend: row["mend"], fund_id: fund_id)
  		month.assign_attributes({fund_return: row["return"]})
  		month.save!
  	end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
=end

end