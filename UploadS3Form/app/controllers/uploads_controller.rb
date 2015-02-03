class UploadsController < ApplicationController
  def index
  	@uploads = Upload.all
  end

  def show
    @upload = Upload.find(params[:id])
  end  	

  def new
  	@upload = Upload.new
  end

  def create
  	@upload = Upload.create( upload_params )

  	if @upload.save
  	  # render json: { message: "success" }, :status => 200
  	  redirect_to @upload
  	else
  	  #need to send an error header, otherwise Dropzone
          #  will not interpret the response as an error:
  	  render json: { error: @upload.errors.full_messages.join(',')}, :status => 400
  	end 
	end

	private

	# Use strong_parameters for attribute whitelisting
	# Be sure to update your create() and update() controller methods.

	def upload_params
	  params.require(:upload).permit(:image)
	end
end
