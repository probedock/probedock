Given /user (\w+) who is an administrator exists/ do |user_name|
  add_named_record user_name, create(:admin, name: user_name)
end
