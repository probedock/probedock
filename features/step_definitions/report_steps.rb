Given /^test result report (.+) was generated(?: (\d+) day(?:s)? ago)?(?: with UID ([a-zA-Z0-9_-]+))? for organization (.+)$/ do |name,days,uid,organization_name|
  options = {
    uid: uid,
    organization: named_record(organization_name)
  }

  if days
    date = days.to_i.days.ago

    options.merge!({
      started_at: date - 3.minutes,
      ended_at: date - 1.minute
    })
  end

  add_named_record name, create(:test_report, options)
end

Given /^test payload (.+) sent by (.+) for version (.+) of project (.+) was used to generate report (.+)$/ do |name,runner_name,version_name,project_name,report_name|
  project = named_record project_name
  project_version = ProjectVersion.where(name: version_name, project: project).first_or_create

  options = {
    runner: named_record(runner_name),
    test_report: named_record(report_name),
    project_version: project_version
  }

  add_named_record name, create(:test_payload, options)
end
