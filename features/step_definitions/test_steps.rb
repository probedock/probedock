Given /^test "(.+)" was created by (.+) with key (.+) for version (.+) of project (.+)$/ do |name,user_name,test_key,project_version,project_name|
  user = named_record user_name
  project = named_record project_name
  project_version = ProjectVersion.where(project_id: project.id, name: project_version).first_or_create

  key = create :test_key, user: user, project: project, key: test_key
  add_named_record test_key, key

  options = {
    name: name,
    key: key,
    project: project,
    last_runner: user,
    project_version: project_version
  }

  add_named_record name, create(:test, options)
end

Given /^test "(.+)" was first run by (.+) for version (.+) of project (.+)$/ do |name,user_name,project_version,project_name|
  user = named_record user_name
  project = named_record project_name
  project_version = ProjectVersion.where(project_id: project.id, name: project_version).first_or_create

  options = {
    name: name,
    project: project,
    first_runner: user,
    last_runner: user,
    project_version: project_version
  }

  add_named_record name, create(:test, options)
end

Given /^test "(.+)"(?: was last run by (.+) and)? has category (.+?)(?: and tags (.+?))?(?: and tickets (.+?))? for version (.+)$/ do |name,runner_name,category_name,tag_names,ticket_names,version_name|
  test = named_record name
  last_runner = runner_name ? named_record(runner_name) : nil
  project_version = ProjectVersion.where(project_id: test.project_id, name: version_name).first_or_create

  description = TestDescription.where(test_id: test.id, project_version_id: project_version.id).first
  description = build :test_description, test: test, project_version: project_version unless description

  description.last_runner = last_runner if last_runner

  organization = project_version.project.organization

  description.category = Category.where(organization_id: organization.id, name: category_name).first_or_create if category_name

  if tag_names
    tag_names.split(',').each do |t|
      tag = create :tag, name: t, organization: organization
      add_named_record t, tag
      description.tags << tag
    end
  end

  if ticket_names
    ticket_names.split(',').each do |t|
      ticket = create :ticket, name: t, organization: organization
      add_named_record t, ticket
      description.tickets << ticket
    end
  end

  description.save!
end
