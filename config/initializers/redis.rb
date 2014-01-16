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
rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'
config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
config = config[rails_env]

host, port, db = config.split /:/

options = { host: host, port: port, db: db.to_i, driver: :hiredis }
options[:logger] = Rails.logger unless ENV['QUEUE'] or ENV['RESQUE'] or Rails.env != 'development'

$redis_db = Redis.new options
$redis = Redis::Namespace.new 'rox', redis: $redis_db
