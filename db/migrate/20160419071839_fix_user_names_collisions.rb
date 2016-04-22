class FixUserNamesCollisions < ActiveRecord::Migration
  def up
    User.all.each do |user|
      normalized_name = if user.human?
        "human||#{user.name.downcase}"
      else
        "technical||#{user.memberships.first.organization.normalized_name}||#{user.name.downcase}"
      end

      User.where(id: user.id).update_all(normalized_name: normalized_name)
    end
  end

  def down
  end
end
