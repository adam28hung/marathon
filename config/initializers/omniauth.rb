# for google
Rails.application.config.middleware.use OmniAuth::Strategies::GoogleOauth2,
    ENV["GOOGLE_OAUTH_CLIENT_ID"], ENV["GOOGLE_OAUTH_KEY"], {client_options: {ssl: {ca_file: ENV['CA_FILE_PATH']}}}