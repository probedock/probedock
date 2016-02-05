Given /^test "(.+)" was created(?: (\d*) ((?:day|week)s?) ago)? by (.+) with key (.+) for version (.+) of project (.+)$/ do |name,interval_count,interval,user_name,test_key,project_version,project_name|
  user = named_record user_name
  project = named_record project_name
  project_version = ProjectVersion.where(project_id: project.id, name: project_version).first_or_create

  key = create :test_key, user: user, project: project, key: test_key
  add_named_record test_key, key

  date = if interval_count
    interval_count.to_i.send(interval).ago
  else
    Time.now
  end

  options = {
    name: name,
    key: key,
    project: project,
    first_runner: user,
    last_runner: user,
    project_version: project_version,
    first_run_at: date,
    created_at: date
  }

  add_named_record name, create(:test, options)
end

Given /^test "(.+)" was first run by (.+)(?: (\d*) ((?:day|week)s?) ago)? for version (.+) of project (.+)$/ do |name,user_name,interval_count,interval,project_version,project_name|
  user = named_record user_name
  project = named_record project_name
  project_version = ProjectVersion.where(project_id: project.id, name: project_version).first_or_create

  date = if interval_count
    interval_count.to_i.send(interval).ago
  else
    Time.now
  end

  options = {
    name: name,
    project: project,
    first_runner: user,
    last_runner: user,
    first_run_at: date,
    project_version: project_version
  }

  add_named_record name, create(:test, options)
end

Given /^test "(.+)"(?: is (passing|failing)(?: and (active|inactive))? and)?(?: was last run by (.+?))?(?:(?: and)? has category (.+?))?(?: and tags (.+?))?(?: and tickets (.+?))? for version (.+)$/ do |name,passing,active,runner_name,category_name,tag_names,ticket_names,version_name|
  test = named_record name
  last_runner = runner_name ? named_record(runner_name) : nil
  project_version = ProjectVersion.where(project_id: test.project_id, name: version_name).first_or_create

  description = TestDescription.where(test_id: test.id, project_version_id: project_version.id).first
  description = build :test_description, test: test, project_version: project_version unless description

  description.last_runner = last_runner if last_runner

  organization = project_version.project.organization

  description.category = Category.where(organization_id: organization.id, name: category_name).first_or_create if category_name

  if passing
    description.passing = passing == 'passing'
  end

  if active
    description.active = active == 'active'
  end

  if tag_names
    tag_names.split(',').each do |t|
      tag = Tag.where(organization: organization, name: t).first_or_create
      add_named_record t, tag
      description.tags << tag
    end
  end

  if ticket_names
    ticket_names.split(',').each do |t|
      ticket = Ticket.where(organization: organization, name: t).first_or_create
      add_named_record t, ticket
      description.tickets << ticket
    end
  end

  description.save!
end
