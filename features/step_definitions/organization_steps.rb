Given /organization (\w+) exists/ do |name|
  options = { name: name.downcase }
  options[:display_name] = name if name != options[:name]
  add_named_record name, create(:organization, options)
end

Given /user (\w+) who is an admin for (\w+) exists/ do |user_name,organization_name|
  org = Organization.where(name: organization_name.downcase).first!
  add_named_record user_name, create(:org_admin, name: user_name, organization: org)
end

Given /user (\w+) who is a technical user for (\w+) exists/ do |user_name,organization_name|
  org = Organization.where(name: organization_name.downcase).first!
  add_named_record user_name, create(:technical_user, name: user_name, organization: org)
end
