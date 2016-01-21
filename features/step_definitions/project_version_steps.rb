Given /^project version (.+) exists for project (.+)(?: with creation date set (?:(1 day|(?:[2-9]|\d{2,}) days) ago))$/ do |name,project_name,nb_days|
  options = {
    name: name.downcase.gsub(/\s+/, '-'),
    project: named_record(project_name)
  }

  if nb_days
    options.merge!({
      created_at: nb_days.split(' ')[0].to_i.days.ago
    })
  end

  options[:display_name] = name if name != options[:name]

  add_named_record name, create(:project_version, options)
end
