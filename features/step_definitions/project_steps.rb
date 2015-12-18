Given /^project (.+) exists within organization (.+)$/ do |name,organization_name|
  options = {
    name: name.downcase.gsub(/\s+/, '-'),
    organization: named_record(organization_name)
  }

  options[:display_name] = name if name != options[:name]

  add_named_record name, create(:project, options)
end
