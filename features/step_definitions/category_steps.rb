Given /^category (.+) exists within organization (.+)$/ do |name,organization_name|
  options = {
    name: name,
    organization_id: named_record(organization_name).id
  }

  category = Category.where(options).first_or_create

  add_named_record name, category
end
