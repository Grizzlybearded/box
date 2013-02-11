class MonthsController < ApplicationController
before_filter :authorize_user, except: [:current_month]
before_filter :authorize_ga, except: [:current_month]

	def create
		@month = Month.new(params[:month])
		if @month.save
			flash[:success] = "New month added"
			redirect_to @month.fund
		else
			redirect_to :back
		end
	end

	def current_month 
		if current_user && current_user.global_admin?
			@funds = Fund.all
		elsif current_user
			@funds = current_user.investor.funds
		else
			@funds = []
		end
		@max = Month.maximum(:mend)
	end

	def current_month_rates
		@funds = current_user.investor.funds
		#loop through the funds
		#check if the correct date is present, if yes, then do operations and put into child array.  if not, then put nil.
		#put another array into the parent array.

		@last_month = Month.maximum(:mend)
		@three_months_ago = @last_month.months_ago(3)

		@parent_array = []
		@child_array = []
		local_array = []

		@funds.each do |i|

			#locally store the last 4 months for the current fund
			local_array = i.months.where(mend: @three_months_ago..@last_month)

			#store the fund name in the first spot
			@child_array << i

			#check if the array has any values 3 months ago.  if yes, do calcs and stor in child array, else store nil values
			if (local_array[0].mend == @three_months_ago) && (local_array.last.mend == @last_month)
			#order of elements stored in array: aum, gross, net
				if local_array.last.aum.present? && local_array[0].aum.present?
					@child_array << ((local_array.last.aum*1.0)/(local_array[0].aum*1.0) - 1)*100.0 #store aum in array
				else
					@child_array << nil
				end
				
				if local_array.last.gross.present? && local_array[0].gross.present?
					@child_array << (local_array.last.gross - local_array[0].gross)
				else
					@child_array << nil
				end
				
				if local_array.last.net.present? && local_array[0].net.present?
					@child_array << (local_array.last.net - local_array[0].net)
				else
					@child_array << nil
				end
			else
				3.times {@child_array << nil}
			end

			#check if the array has values for the 3 most recent months.  if yes, calc return and store in child array. else, store nil values
			if ( local_array[-1].mend == @last_month && 
				local_array[-2].mend == @last_month.months_ago(1) &&
				local_array[-3].mend == @last_month.months_ago(2) &&
				local_array[-1].fund_return.present? &&
				local_array[-2].fund_return.present? &&
				local_array[-3].fund_return.present?)

				@child_array << (
					(local_array[-1].fund_return/100.0 +1)*
					(local_array[-2].fund_return/100.0 +1)*
					(local_array[-3].fund_return/100.0 +1) -1
					)*100.0
			else
				@child_array << nil
			end
			
			#wipe local variables clean and store child array in parent array
			@parent_array << @child_array
			local_array = []
			@child_array = []

		end

	end

	def edit
		@month = Month.find(params[:id])
	end

	def update
		@month = Month.find(params[:id])
		if @month.update_attributes(params[:month])
			flash[:success] = "Month updated"
			redirect_to @month.fund
		else
			render 'edit'
		end
	end

	def destroy
		Month.find(params[:id]).destroy
		flash[:success] = "Month record destroyed"
		redirect_to :back
	end

	def import
		Month.import(params[:file])
		redirect_to root_url, notice: "Fund data imported"
	end

end