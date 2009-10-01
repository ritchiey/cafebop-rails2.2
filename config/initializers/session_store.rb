# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ordertest_session',
  :secret      => 'ff0a342d4b1e43c6778e14624eeb09fc16e65e787697bad6527032d6f963682957c3886c757d6ff6e40eb08b594ce926c6e7c256043a521d94d3162c4ee08d1d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
