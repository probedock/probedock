class RemoveUniqueUserConstraint < ActiveRecord::Migration
  def up
    remove_index :users, :name

    # This column require the space for <human|technical>[-<organizationNormalizedName>]-<name.downcase>
    add_column :users, :normalized_name, :string, null: true, limit: 100

    add_index :users, :normalized_name, unique: true

    User.all.each do |user|
      user.save
    end

    change_column :users, :normalized_name, :string, null: false
  end

  def down
    add_index :users, :name, unique: true
    remove_index :users, :normalized_name
    remove_column :users, :normalized_name
  end
end
