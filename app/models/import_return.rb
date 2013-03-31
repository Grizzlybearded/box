class ImportReturn
  
	# switch to Activemodel::Model in Rails 4

	extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations

	attr_accessor :file

	def initialize(attributes = {})
		attributes.each { |name, value| send("#{name}=", value) }
	end

	def persisted?
		false
	end

	def save(investor)
		@investor = investor
		if imported_returns(@investor).map(&:valid?).all?
			imported_returns(@investor).each(&:save!)
			true
		else
			imported_returns(@investor).each_with_index do |fund_return, index|
				fund_return.errors.full_messages.each do |message|
					errors.add :base, "Row #{index+2}: #{message}"
				end
			end
			false
		end
	end

	def imported_returns(investor)
		@imported_returns ||= load_imported_returns(investor)
	end

	def load_imported_returns(investor)
		@investor = investor
		spreadsheet = open_spreadsheet
		header = spreadsheet.row(1)
		(2..spreadsheet.last_row).map do |i|
			row = Hash[[header, spreadsheet.row(i)].transpose]	
			fund = @investor.funds.find_by_name(row["Name"])
			month = Month.find_by_mend_and_fund_id(row["Date"].at_beginning_of_month, fund == nil ? nil : fund.id) || 
  			Month.new(mend: row["Date"].at_beginning_of_month, fund_id: (fund == nil ? nil : fund.id))
			month.assign_attributes({fund_return: row["Return"]})
			month
		end
	end

	def open_spreadsheet
		case File.extname(file.original_filename)
		when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
		else raise "Unknown file type: #{file.original_filename}"
		end
	end
end














