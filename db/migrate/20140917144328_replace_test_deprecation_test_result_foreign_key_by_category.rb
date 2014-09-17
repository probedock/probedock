class ReplaceTestDeprecationTestResultForeignKeyByCategory < ActiveRecord::Migration
  class Category < ActiveRecord::Base; end

  class TestResult < ActiveRecord::Base
    belongs_to :category
  end

  class TestDeprecation < ActiveRecord::Base
    belongs_to :category
    belongs_to :test_result
  end

  def up
    add_column :test_deprecations, :category_id, :integer
    TestDeprecation.reset_column_information

    Category.all.to_a.each do |category|
      TestDeprecation.joins(test_result: :category).where('categories.id = ?', category.id).update_all category_id: category.id
    end

    remove_foreign_key :test_deprecations, :test_results
    remove_column :test_deprecations, :test_result_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
