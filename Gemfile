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

gem 'rails', '4.1.7'

gem 'pg'

gem 'foreigner'

# Assets
gem 'slim-rails'
gem 'less-rails'
gem 'stylus'
gem 'therubyracer'
gem 'uglifier', '>= 1.3.0'

# Authentication & Authorization
gem 'bcrypt'
gem 'role_model'
gem 'json-jwt'

# API
gem 'jbuilder'

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
gem 'tableling-rails'

# Fast JSON
gem 'oj'

# Tools
gem 'rake-version'
gem 'paint'
gem 'highline'

group :production do
  gem 'unicorn'
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
  gem 'rox-client-rspec', '~> 0.4.1'
  gem 'rspec-rails', '~> 3.1'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'minitest'

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
