class FixMissingLimitsOnStrings < ActiveRecord::Migration
  def up
    change_column :users, :password_digest, :string, limit: 60
    change_column :user_registrations, :otp, :string, limit: 150
  end

  def down
    change_column :user_registrations, :otp, :string
    change_column :users, :password_digest, :string
  end
end
