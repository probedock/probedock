class RemoveUniqueUserConstraint < ActiveRecord::Migration
  def up
    remove_index :users, :name

    # This column require the space for <human|technical>[-<organizationNormalizedName>]-<name.downcase>
    add_column :users, :normalized_name, :string, null: true, limit: 100

    add_index :users, :normalized_name, unique: true

    User.all.each do |user|
      normalized_name = if user.human?
        "human-#{user.name.downcase}"
      else
        "technical-#{user.memberships.first.organization.normalized_name}-#{user.name.downcase}"
      end

      User.where(id: user.id).update_all(normalized_name: normalized_name)
    end

    change_column :users, :normalized_name, :string, null: false
  end

  def down
    add_index :users, :name, unique: true
    remove_index :users, :normalized_name
    remove_column :users, :normalized_name
  end
end
