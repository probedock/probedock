# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of Probe Dock.
#
# Probe Dock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Probe Dock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.

api_log_file = File.join Rails.root, 'log', "api.#{Rails.env}.log"
$api_logger = Logger.new api_log_file, 3, 1048576

payload_log_file = File.join Rails.root, 'log', "payload.#{Rails.env}.log"
$payload_logger = Logger.new payload_log_file, 10, 1048576
