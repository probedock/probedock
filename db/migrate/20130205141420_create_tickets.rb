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
class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :name, :null => false
      t.timestamps :null => false
    end

    create_table :test_infos_tickets, :id => false do |t|
      t.references :test_info, :null => false
      t.references :ticket, :null => false
    end

    add_index :tickets, :name, :unique => true
    add_index :test_infos_tickets, [ :test_info_id, :ticket_id ], :unique => true
    add_foreign_key :test_infos_tickets, :test_infos
    add_foreign_key :test_infos_tickets, :tickets
  end
end
