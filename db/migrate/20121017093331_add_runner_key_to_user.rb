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
class AddRunnerKeyToUser < ActiveRecord::Migration

  class User < ActiveRecord::Base; end

  def up
    add_column :users, :runner_key, :string, :limit => 32
    add_index :users, :runner_key, :unique => true

    keys = []
    User.all.each do |u|
      while keys.include?(key = generate_runner_key); end
      u.update_attribute :runner_key, key
      keys << key
    end

    change_column :users, :runner_key, :string, :null => false, :limit => 32
  end

  def down
    remove_index :users, :runner_key
    remove_column :users, :runner_key
  end

  private

  # Generates a random runner key of 32 hexadecimal characters.
  def generate_runner_key
    SecureRandom.hex 16 # result string is twice as long as n
  end
end
