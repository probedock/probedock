# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
# config/initializers/redis.rb must be loaded first
Resque.redis = $redis_db
Resque.redis.namespace = 'probedock:resque'

if ENV['PROBE_DOCK_LOG_TO_STDOUT']
  Resque.logger = Logger.new STDOUT
else
  Resque.logger = Logger.new Rails.root.join('log', "resque.#{Rails.env}.log")
end

Resque.logger.level = Rails.env == 'production' ? Logger::WARN : Logger::INFO
