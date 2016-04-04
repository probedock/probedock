Given /^project (.+) exists within organization (.+?)(?: with repo url (.+))?$/ do |name,organization_name,repo_url|
  options = {
    name: name.downcase.gsub(/\s+/, '-'),
    organization: named_record(organization_name)
  }

  options[:display_name] = name if name != options[:name]
  options[:repo_url] = repo_url if repo_url

  add_named_record(name, create(:project, options))
end

Given /^the project (.+) updated with the repo url pattern (.+)$/ do |name,repo_url_pattern|
  project = named_record(name)
  project.repo_url_pattern = repo_url_pattern
  project.save
end