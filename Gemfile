# Copyright (c) 2012-2014 Lotaris SA
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

gem 'rails', '4.1.5'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Database
group :mysql do
  gem 'mysql2'
end

group :postgresql do
  gem 'pg'
end

gem 'foreigner'

# Templating
gem 'haml'
gem 'haml-rails'
gem 'markdown-rails'
gem 'redcarpet'
gem 'pygments.rb'

# Authentication & Authorization
gem 'devise', '~> 3.2.2'
gem 'devise_ldap_authenticatable', git: 'https://github.com/Prevole/devise_ldap_authenticatable.git', branch: 'group-lookup-config'
gem 'cancan'
gem 'role_model'

# Memory Database
gem 'redis'
gem 'hiredis'
gem 'redis-namespace'

# Background Processing
gem 'resque'
gem 'resque-workers-lock'

# Model Extensions
gem 'simple_states' # state machines
gem 'strip_attributes' # trimming

# Fast JSON
gem 'oj'

# Assets
gem 'sass-rails', '>= 3.2'
gem 'bootstrap-sass', '~> 3.2'
gem 'autoprefixer-rails'
gem 'jquery-rails'
gem 'backbone-on-rails'
#gem 'marionette-rails' # currently provided by tableling-rails
gem 'tableling-rails'
gem 'haml_coffee_assets'
gem 'therubyracer'
gem 'execjs'
gem 'clah-rails'
gem 'highcharts-rails', '~> 3.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby
gem 'uglifier', '>= 1.0.3'
gem 'select2-rails'
gem 'backbone-relational-hal-rails'

# Tools
gem 'rake-version'
gem 'paint'

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
  gem 'minitest' # FIXME: see if this can be removed when capybara/rspec are upgraded

  gem 'resque-pool'

  gem 'guard'
  gem 'guard-shell'
  gem 'guard-process'
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
