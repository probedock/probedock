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
class AddMetricKeys < ActiveRecord::Migration
  KEY_CHARACTERS = (48..57).to_a + (97..122).to_a

  def up

    say_with_time "adding metric key to #{Project.count} projects" do
      add_metric_key Project, :projects
    end

    say_with_time "adding metric key to #{Category.count} categories" do
      add_metric_key Category, :categories
    end

    say_with_time "adding metric key to #{User.count} users" do
      add_metric_key User, :users
    end
  end

  def down
    remove_column :projects, :metric_key
    remove_column :categories, :metric_key
    remove_column :users, :metric_key
  end

  def add_metric_key model, table
    cache = []
    add_column table, :metric_key, :string, limit: 5
    model.pluck(:id).each{ |id| model.where(id: id).update_all metric_key: new_metric_key(cache) }
    change_column table, :metric_key, :string, null: false, limit: 5
    add_index table, :metric_key, unique: true
  end

  def new_metric_key cache = []
    next while cache.include?(key = ([ nil ] * 5).map{ KEY_CHARACTERS.sample.chr }.join)
    key
  end
end
