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
class CreateCategories < ActiveRecord::Migration
  class Category < ActiveRecord::Base; end
  class TestInfo < ActiveRecord::Base; end

  def up

    create_table :categories do |t|
      t.string :name, null: false
      t.datetime :created_at, null: false
    end

    add_index :categories, :name, unique: true

    Category.reset_column_information

    add_column :test_infos, :category_id, :integer

    category_names = TestInfo.uniq.pluck('category').compact.sort
    categories = say_with_time "creating #{category_names.length} categories" do
      category_names.inject([]){ |memo,name| memo << Category.new.tap{ |c| c.name = name; c.save! } }
    end

    categories.each do |category|
      rel = TestInfo.where category: category.name
      say_with_time "updating #{rel.count} tests with category '#{category.name}'" do
        rel.update_all category_id: category.id
      end
    end

    add_foreign_key :test_infos, :categories
    remove_column :test_infos, :category
  end

  def down

    add_column :test_infos, :category, :string

    Category.all.each do |category|
      rel = TestInfo.where category_id: category.id
      say_with_time "updating #{rel.count} tests with category '#{category.name}'" do
        rel.update_all category: category.name
      end
    end

    remove_foreign_key :test_infos, :category
    remove_column :test_infos, :category_id
    drop_table :categories

    add_index :test_infos, :category
  end
end
