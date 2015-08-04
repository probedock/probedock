Given /user (\w+) who is a Probe Dock admin exists/ do |user_name|
  add_named_record user_name, create(:admin, name: user_name)
end
