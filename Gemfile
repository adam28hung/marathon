source 'https://rubygems.org'

#ruby=ruby-2.2.2

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'twitter-bootstrap-rails'
gem 'high_voltage', '~> 2.3.0'
gem "figaro"
gem 'friendly_id'
gem 'babosa'
gem 'jquery-turbolinks'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem "parse-ruby-client" 

group :production, :staging do
  gem 'mysql2'
end

group :development do
  gem 'thin'
  gem 'meta_request'
  #gem 'faker'
  #gem 'populator'
  #gem 'brakeman', :require => false
  # gem 'sqlite3'
  #gem 'sextant'
  #gem 'xray-rails'
  gem 'capistrano',  '~> 3.1'
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-passenger'
  # gem 'capistrano-bundler', '~> 1.1.2', require: false
  
  # gem 'rvm-capistrano'
  # gem 'capistrano-ext'
  # gem 'lol_dba'
  # lol_dba db:find_indexes
  #gem "better_errors"

end

gem 'sucker_punch', '~> 1.0'
# gem 'mailgun_rails'

# gem 'recaptcha', :require => "recaptcha/rails"

#image upload
gem 'remotipart'
gem 'mini_magick'
gem 'carrierwave'

gem 'devise'

gem "rails-alertify"
gem 'kaminari'

gem 'ransack', github: 'activerecord-hackery/ransack', branch: 'rails-4.2'
gem 'simple_form'

gem 'sanitize'
#gem 'geokit-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

