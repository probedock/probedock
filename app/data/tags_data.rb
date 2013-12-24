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

class TagsData

  def self.cloud
    JsonCache.new(:tag_cloud){ cloud_data.deep_stringify_keys! }
  end

  def self.sized_cloud contents, max_size
    contents.sort!{ |a,b| b['count'] <=> a['count'] }
    contents = contents.first max_size if max_size >= 1
    contents.sort!{ |a,b| a['name'].casecmp b['name'] }
    contents
  end

  private

  def self.cloud_data
    Tag.select('tags.name, count(test_infos.id) as tests_count').joins(:test_infos).group('tags.name').having('count(test_infos.id) > 0').to_a.collect do |tag|
      { name: tag.name, count: tag.tests_count }
    end
  end
end
