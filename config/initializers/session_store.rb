# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_yesl_website_session',
  :secret      => 'fdf77ea37d945274787322b9aafcaa867b8ec22a85a67ccfda7c4ffde6b28e2fe139e118cf06e00368a92978d799bee924f60c6ce0f90a524bbc49bdcd83be0e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
