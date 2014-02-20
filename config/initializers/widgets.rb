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
config = HashWithIndifferentAccess.new YAML.load_file(Rails.root.join('config', 'rox-center.yml'))

test_widgets = %w(info permalink)

raise "test_widgets configuration must be an array" if config[:test_widgets] and !config[:test_widgets].kind_of?(Array)
(config[:test_widgets] || test_widgets).each do |name|
  raise "Unknown test widget #{name}" unless test_widgets.include? name.to_s
  Rails.application.test_widgets << name.to_s.to_sym
end
