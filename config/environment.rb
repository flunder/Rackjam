# Load the rails application
require File.expand_path('../application', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
Synth4::Application.initialize!

# Use built in html parser for scrapi instead of Tidy gem  
Scraper::Base.parser :html_parser
