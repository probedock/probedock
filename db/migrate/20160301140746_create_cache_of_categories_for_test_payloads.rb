class CreateCacheOfCategoriesForTestPayloads < ActiveRecord::Migration
  def up
    create_table :categories_test_payloads, id: false do |t|
      t.integer :category_id, null: false
      t.integer :test_payload_id, null: false
      t.index [ :category_id, :test_payload_id ], unique: true, name: 'index_categories_test_payloads_on_category_and_payload'
      t.foreign_key :categories
      t.foreign_key :test_payloads
    end

    i = 0
    total = TestPayload.count

    # set categories for payloads
    TestPayload.select(:id, :state).find_in_batches batch_size: 500 do |payloads|

      say_with_time "set categories for payloads #{i + 1}-#{i + payloads.length} (out of #{total})`" do
        payloads.each do |payload|
          payload.categories = Category.joins(test_results: :test_payload).where('test_payloads.id = ?', payload.id).uniq.to_a
        end

        payloads.length
      end

      i += payloads.length
    end
  end

  def down
    drop_table :categories_test_payloads
  end
end
