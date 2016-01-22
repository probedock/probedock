Given /^project version (.+) exists for project (.+?)(?: since (?:(1 day|(?:[2-9]|\d{2,}) days) ago))?$/ do |name,project_name,nb_days|
  options = {
    name: name,
    project: named_record(project_name)
  }

  if nb_days
    options.merge!({
      created_at: nb_days.split(' ')[0].to_i.days.ago
    })
  end

  add_named_record name, create(:project_version, options)
end
