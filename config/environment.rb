# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Box::Application.initialize!

# added to create ensure host
ActionMailer::Base.default_url_options = { :host => "nameless-tundra-6004.herokuapp.com" }

# Disable delivery errors, bad email addresses will be ignored
ActionMailer::Base.raise_delivery_errors = true

# Change mail delivery to either :smtp, :sendmail, :file, :test
ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
	:user_name => "app11629203@heroku.com",
	:password => "goldenshoe14",
	:domain => "nameless-tundra-6004.herokuapp.com",
	:address => "smtp.sendgrid.net",
	:port => 465,
	:authentication => :plain,
	:enable_starttls_auto => true
}