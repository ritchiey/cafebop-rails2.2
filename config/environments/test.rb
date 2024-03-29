# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test
config.action_mailer.default_url_options = { :host => 'www.example.com', :port=>3001 }

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

class ActiveRecord::Base
  def self.paperclip_options(type)
    {  
      :url=>"/assets/#{type}/:id/:style/:basename.:extension",
      :path=>":rails_root/public/assets/#{type}/:id/:style/:basename.:extension"
    }
  end
end           


config.gem "rspec", :lib=>false, :version=> ">=1.2.2"
config.gem "rspec-rails", :lib=>false, :version=> ">=1.2.2"
# config.gem "cucumber", :lib=>false, :version=> ">=0.4.4"  
# config.gem "cucumber-rails", :lib=>false
config.gem 'pickle', :lib => false, :version=> ">=0.1.21"
config.gem 'database_cleaner', :version=>'>= 0.5.0'
config.gem 'webrat', :version=>'>= 0.7.0'
config.gem 'bullet', :source => 'http://gemcutter.org'

config.after_initialize do
  Bullet.enable = true 
  Bullet.alert = true
  Bullet.bullet_logger = true  
  Bullet.console = true
  Bullet.growl = false
  Bullet.rails_logger = true
  Bullet.disable_browser_cache = true
end