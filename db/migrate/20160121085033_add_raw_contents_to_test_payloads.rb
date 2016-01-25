class AddRawContentsToTestPayloads < ActiveRecord::Migration
  def change
    add_column :test_payloads, :raw_contents, :text
  end
end
