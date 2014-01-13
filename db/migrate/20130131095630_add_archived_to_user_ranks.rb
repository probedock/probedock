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
class AddArchivedToUserRanks < ActiveRecord::Migration
  class User < ActiveRecord::Base; end
  class Ranking < ActiveRecord::Base; end
  class UserRank < ActiveRecord::Base; end

  def up
    add_column :user_ranks, :archived, :boolean, :null => false, :default => false

    rankings = Ranking.all
    User.all.each do |user|
      rankings.each do |ranking|
        last_rank = UserRank.where( :user_id => user.id, :ranking_id => ranking.id ).order('created_at DESC').limit(1).first
        UserRank.update_all([ 'archived = ?', true ], [ 'user_id = ? AND ranking_id = ? AND id != ?', user.id, ranking.id, last_rank.try(:id) ])
      end
    end
  end

  def down
    remove_column :user_ranks, :archived
  end
end
