# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Box::Application.initialize!

Box::Application.configure do 
	# Disable delivery errors, bad email addresses will be ignored
	config.action_mailer.raise_delivery_errors = true

	config.action_mailer.default_url_options = { :host => "nameless-tundra-6004.herokuapp.com" }
	# Change mail delivery to either :smtp, :sendmail, :file, :test
	config.action_mailer.delivery_method = :smtp
end

ActionMailer::Base.smtp_settings = {
	:user_name => "app11629203@heroku.com",
	:password => "goldenshoe14",
	:domain => "https://nameless-tundra-6004.herokuapp.com",
	:address => "smtp.sendgrid.net",
	:port => 465,
	:authentication => :plain,
	:enable_starttls_auto => true
}