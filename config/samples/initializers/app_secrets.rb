# Be sure to restart your server when you modify this file.

# Secret keys for verifying the integrity of signed cookies and generating user passwords.
# If you change the secret token, all old signed cookies will become invalid!
# Make sure each secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can generate cryptographically secure secret keys with `rake secret`.
ROXCenter::Application.config.secret_token = '[YOUR_SECRET_TOKEN]'
ROXCenter::Application.config.secret_key_base = '[YOUR_SECRET_KEY_BASE]'
ROXCenter::Application.config.devise_secret_key = '[YOUR_DEVISE_SECRET_KEY]'
