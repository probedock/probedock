Given /^(private )?organization (.+) exists( and is inactive)?/ do |public_access,name,inactive|
  options = { name: name.downcase.gsub(/\s+/, '-') }
  options[:display_name] = name if name != options[:name]
  options[:active] = inactive.nil?
  add_named_record(name, create(:organization, options))
end

Given /^public organization (.+) exists( and is inactive)?/ do |name,inactive|
  options = { name: name.downcase.gsub(/\s+/, '-'), public_access: true }
  options[:display_name] = name if name != options[:name]
  options[:active] = inactive.nil?
  add_named_record(name, create(:organization, options))
end

Given /user (\w+)(?: with primary email (.+?))? who is a member of (.+) exists/ do |user_name,primary_email,organization_name|
  org = Organization.where(name: organization_name.downcase.gsub(/\s+/, '-')).first!

  if primary_email
    email = create(:email, address: primary_email)
    add_named_record(user_name, create(:org_member, name: user_name, organization: org, primary_email: email))
  else
    add_named_record(user_name, create(:org_member, name: user_name, organization: org))
  end
end

Given /user (\w+)(?: with primary email (.+?))? who is an admin of (.+) exists/ do |user_name,primary_email,organization_name|
  org = Organization.where(name: organization_name.downcase.gsub(/\s+/, '-')).first!

  if primary_email
    email = create(:email, address: primary_email)
    add_named_record(user_name, create(:org_admin, name: user_name, organization: org, primary_email: email))
  else
    add_named_record(user_name, create(:org_admin, name: user_name, organization: org))
  end
end

Given /user (\w+) who is a technical user of (.+) exists(?: since (\d*) ((?:day|week)s?) ago)?/ do |user_name,organization_name,interval_count,interval|
  org = Organization.where(name: organization_name.downcase.gsub(/\s+/, '-')).first!

  date = if interval_count
    interval_count.to_i.send(interval).ago
  else
    Time.now
  end

  add_named_record(user_name, create(:technical_user, name: user_name, organization: org, created_at: date, updated_at: date))
end

Given /user (\w+) is(?: also)? a member of (.+)/ do |user_name,organization_name|
  user = named_record(user_name)
  org = named_record(organization_name)
  create(:membership, user: user, organization: org)
end

Given /user (\w+) is(?: also)? an admin of (.+)/ do |user_name,organization_name|
  user = named_record(user_name)
  org = named_record(organization_name)
  create(:membership, user: user, organization: org, roles: [ :admin ])
end
