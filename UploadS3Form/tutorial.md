1. Create an Amazon Web Service account at http://aws.amazon.com/

2. Log into the console and go to S3 under "Storage & Content Delivery"

3. Click on "Create Bucket" and give it the name you want and select "US Standard" under Region.

4. Right click your on your bucket and select "properties"

5. Under properties click on "permissions". Click on "add more permissions", under Grantee select Everyone, and select Upload/Delete, View Permissions and Edit Permissions. Save the bucket's permissions.

![Image of Bucket creation]
(https://github.com/luisjar/Others/blob/master/amazonS3.png)

6. Click on your account's name at the top right of the website. A dropdown menu displays and click over "Security and Credentials". Then click "continue to security credentials" on the pop up window.

7. Click on "Access Keys (Access Key ID and Secret Access Key). Create a new Access Key if you don't have one yet. Copy and save the access key and secret access key in a safe place. You are going to be able to see your secrete access key just once.

8. Create your rails app. On your command line type: 

    $ rails new theNameOfYourAppHere --database=postgresql


9. On Gemfile add the following gems:

		gem "paperclip", "~> 4.1"
		gem 'aws-sdk'
		gem 'dotenv-rails', :groups => [:development, :test]


10. Install the gems. On command line:

    $ bundle install


11. Now create your model. This model is called "upload" but you can call it whatever you want. On command line:

    $ rails g model upload


12. Then add paperclip attachments to your upload model. To do this, simply run the paperclip generator as so

    $ rails g paperclip upload image


13. Paperclip just added your migration files. Now you just need to migrate your database and add the respective tables and columns. On command line:

    $ rake db:migrate


14. The next step is to update the model code. You need to use has_attached_file to tell it the name of the attachment field you specified when you ran the migration. There are also a couple of validations which you can tweak as you wish. Add the following to your upload.rb file: 

		class Upload < ActiveRecord::Base
			has_attached_file :image, :styles => { :medium => "300x300>",:thumb => "100x100>" }
			
			validates_attachment :image, 
					     :presence => true,
					     :content_type => { :content_type => /\Aimage\/.*\Z/ },
					     :size => { :less_than => 5.megabyte }

		end


15. Next up, create a controller uploads with the new action which will interact with the user and enable him/her upload images and save them to the database. On command line

    $ rails g controller uploads new


16. Complete the controller uploads with the following (uploads_controller.rb):

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


17. Add the following to the routes.rb file. Your routes depend on the way you want your site to work, for the purposes of this gist, we are just adding the following (new.html.erb file):

		Rails.application.routes.draw do
		 root 'uploads#new'
		 resources :uploads
		end


18. Now replace the contents of your uploads new view with the following upload form:

		<h1>Add a new Image</h1>
		<%= form_for @upload, :html => { :multipart => true } do |f| %>
		  
		  <%= f.file_field :image %>
			<%= f.submit "Upload" %>  
		<% end %>


19. Create a show.html.erb file under views folder and add the following code in order to see the uploaded image to S3

		<h1>Pictures</h1>
		<%= image_tag @upload.image.url(:medium) %>



20. On the development.rb file, under config=>enviroments, add the following code at the end of the file:

		  config.paperclip_defaults = {
		  :storage => :s3,
		  :s3_credentials => {
		    :bucket => ENV['S3_BUCKET']
		  }


21. Add the same code at the end of production.rb, under config=>enviroments:

		  config.paperclip_defaults = {
		  :storage => :s3,
		  :s3_credentials => {
		    :bucket => ENV['S3_BUCKET']
		  }

22. Create a file called aws.yml under config. On this file add the following lines:

		development:
		  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
		  secret_access_key: <%= ENV['AWS_SECRET_KEY_ID'] %>

		production:
		  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
		  secret_access_key: <%= ENV['AWS_SECRET_KEY_ID'] %>


23. Create a file .env under the main folder of your application, at the same level of Gemfile and Gemfile.lock. On this file add the following code. Here you are going to paste the access key, secret access key provided by Amazon S3 (from step 7) and S3 bucket's name. 

		AWS_ACCESS_KEY_ID=Here goes the access key ID
		AWS_SECRET_ACCESS_KEY=here goes the secret access key 

		S3_BUCKET=here goes the name of your bucket in Amazon S3

24. Under the root folder, go to .gitignore file. At the bottom type .env. The .gitignore makes sure that that file does not get pushed to github or heroku. The files written there are ignored by git when you commit.


25. Your image upload application should now be working and your pictures should be saved in Amazon S3. The method used to save and store the access key and secret access key is being handled by the "dotenv-rails" gem right now and this will only work for development purposes and under localhost. Do not commit and push these keys to github because they will notice that you are making a private key public.







