class ImportReturnsController < ApplicationController
before_filter :authorize_user
  
  def new
  	@import_return = ImportReturn.new
  end

  def create
  	@import_return = ImportReturn.new(params[:import_return])
  	if @import_return.save(current_user.investor)
  		redirect_to root_path, notice: "Returns imported successfully."
  	else
  		render 'new'
  	end
  end
end
