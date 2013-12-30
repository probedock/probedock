# Copyright (c) 2012-2013 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
source 'https://rubygems.org'

gem 'rails', '4.0.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

gem 'haml'
gem 'foreigner'

gem 'devise', '~> 3.2.2'
gem 'devise_ldap_authenticatable', git: 'https://github.com/Prevole/devise_ldap_authenticatable.git', branch: 'group-lookup-config'
gem 'cancan'
gem 'role_model'
gem 'rake-version'
gem 'tableling-rails'
gem 'select2-rails'

gem 'redis'
gem 'hiredis'
gem 'redis-namespace'
gem 'resque'

gem 'markdown-rails'
gem 'redcarpet'
gem 'pygments.rb'

# Fast JSON
gem 'oj'

gem 'strip_attributes'

gem 'paint'

# Assets
gem 'sass-rails'
gem 'jquery-rails'
gem 'anjlab-bootstrap-rails', '~> 2.3', :require => 'bootstrap-rails'
gem 'compass-rails'
gem 'backbone-on-rails'
#gem 'marionette-rails' # currently provided by tableling-rails
gem 'haml_coffee_assets'
gem 'therubyracer'
gem 'execjs'
gem 'i18n-js'
gem 'clah-rails'
gem 'highcharts-rails', '~> 3.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby
gem 'uglifier', '>= 1.0.3'

group :production do
  gem 'unicorn', '4.6.2'
end

group :development do
  gem 'quiet_assets' # used to silence asset logs
  gem 'silencer' # used to silence status polling logs
  gem 'hpricot'
  gem 'ruby_parser'
end

group :development, :test do
  gem 'thin'
  gem 'httparty'
  gem 'rox-client-rspec', '~> 0.3.1'
  gem 'rspec-rails', '~> 2.14'

  gem 'guard'
  gem 'guard-resque'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver', '2.39.0'
  gem 'sqlite3'
  gem 'factory_girl'
  gem 'shoulda'
  gem 'resque_spec'
  gem 'database_cleaner'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
