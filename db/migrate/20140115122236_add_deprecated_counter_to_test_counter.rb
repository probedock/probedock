class AddDeprecatedCounterToTestCounter < ActiveRecord::Migration

  def change
    change_table :test_counters, bulk: true do |t|
      t.integer :deprecated_counter, null: false, default: 0
      t.integer :total_deprecated
    end
  end
end
