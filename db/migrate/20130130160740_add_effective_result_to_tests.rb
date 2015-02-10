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
class AddEffectiveResultToTests < ActiveRecord::Migration

  class TestInfo < ActiveRecord::Base
    has_many :test_results
  end

  class TestResult < ActiveRecord::Base; end

  def up
    add_column :test_infos, :effective_result_id, :integer
    add_foreign_key :test_infos, :test_results, column: 'effective_result_id'

    TestInfo.select(:id).all.each do |test|
      last_result = test.test_results.select(:id).order('created_at DESC').limit(1).first
      test.update_attribute :effective_result_id, last_result.id if last_result
    end
  end

  def down
    remove_foreign_key :test_infos, :effective_result
    remove_column :test_infos, :effective_result_id
  end
end
