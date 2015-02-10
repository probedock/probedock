# Copyright (c) 2015 42 inside
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
class CreateAppSettings < ActiveRecord::Migration
  class Setting < ActiveRecord::Base; end
  module Settings; end
  class Settings::App < ActiveRecord::Base; self.table_name = 'app_settings'; end

  def up

    measure_lifespan = YAML::load Setting.where(var: 'measure_lifespan').first.try(:value) || 86400
    ticketing_system_url = YAML::load Setting.where(var: 'ticketing_system_url').first.try(:value)

    drop_table :settings

    create_table :app_settings do |t|
      t.integer :measure_lifespan, null: false
      t.string :ticketing_system_url
      t.datetime :updated_at, null: false
    end

    Settings::App.reset_column_information

    say_with_time "converting settings" do
      Settings::App.new.tap do |s|
        s.measure_lifespan = measure_lifespan
        s.ticketing_system_url = ticketing_system_url if ticketing_system_url.present?
      end.save!
    end
  end

  def down

    settings = Settings::App.first

    create_table :settings do |t|
      t.string :var, :null => false
      t.text   :value, :null => true
      t.integer :thing_id, :null => true
      t.string :thing_type, :limit => 30, :null => true
      t.timestamps
    end
    
    add_index :settings, [ :thing_type, :thing_id, :var ], :unique => true

    Setting.reset_column_information

    say_with_time "converting settings" do
      Setting.new.tap do |s|
        s.var = 'measure_lifespan'
        s.value = YAML.dump settings.measure_lifespan
      end.save!

      Setting.new.tap do |s|
        s.var = 'ticketing_system_url'
        s.value = YAML.dump settings.ticketing_system_url
      end.save!
    end

    drop_table :app_settings
  end
end
