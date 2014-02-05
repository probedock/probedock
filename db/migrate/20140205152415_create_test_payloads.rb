class CreateTestPayloads < ActiveRecord::Migration

  def change
    create_table :test_payloads do |t|

      t.text :contents, null: false
      t.string :state, null: false, limit: 12
      t.datetime :received_at, null: false
      t.datetime :processing_at
      t.datetime :processed_at
      t.timestamps null: false

      t.integer :user_id, null: false
      t.foreign_key :users

      t.index :state
    end
  end
end
