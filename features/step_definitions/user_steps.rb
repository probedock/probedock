Given /user (\w+) exists(?: with e-mail (.*))?/ do |user_name,user_email|
  options = { name: user_name }
  options[:primary_email] = create :email, address: user_email if user_email.present?
  add_named_record user_name, create(:user, options)
end

Given /user (\w+) who is a Probe Dock admin exists/ do |user_name|
  add_named_record user_name, create(:admin, name: user_name)
end
