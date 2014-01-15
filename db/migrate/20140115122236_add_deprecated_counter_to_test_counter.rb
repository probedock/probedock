class AddDeprecatedCounterToTestCounter < ActiveRecord::Migration

  def change
    add_column :test_counters, :deprecated_counter, :integer, null: false, default: 0
    add_column :test_counters, :total_deprecated, :integer
  end
end
