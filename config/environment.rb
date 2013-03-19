# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Box::Application.initialize!

ActionMailer::Base.smtp_settings = {
	:user_name => "app11629203@heroku.com",
	:password => "goldenshoe14",
	:domain => "https://nameless-tundra-6004.herokuapp.com",
	:address => "smtp.sendgrid.net",
	:port => 465,
	:authentication => :plain,
	:enable_starttls_auto => true
}