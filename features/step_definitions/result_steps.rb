def create_test_result(name, test_name, new_test, passing, active, category_name, first, interval_count, interval, runner_name, execution_time, payload_name, payload_index, project_version, custom_values)
  runner = named_record(runner_name)
  project_version = named_record(project_version)
  payload = named_record(payload_name)
  test = named_record(test_name)

  date = if interval_count
    interval_count.to_i.send(interval).ago
  else
    Time.now
  end

  options = {
    name: test_name,
    runner: runner,
    project_version: project_version,
    test_payload: payload,
    run_at: date,
    test: test
  }

  # Set results status
  options[:passed] = !passing || passing == 'passing'
  options[:active] = !active || active == 'active'

  # Update the counts related to states
  payload.results_count += 1
  payload.passed_results_count += 1 if options[:passed]
  payload.inactive_results_count += 1 unless options[:active]
  payload.inactive_passed_results_count += 1 if !options[:active] && options[:passed]

  options[:new_test] = new_test == 'new' || !first.nil?

  if execution_time
    options[:duration] = execution_time.to_i
  end

  if category_name
    category = named_record(category_name) if named_record_exists(category_name)

    if category.nil?
      category = create(:category, name: category_name)
      add_named_record(category_name, category)
      payload.categories << category
    end

    options[:category] = category
  end

  if custom_values
    options[:custom_values] = MultiJson.load(custom_values)
  end

  options[:payload_index] = if payload_index
    payload_index
  else
    TestResult.select('COALESCE(MAX(payload_index) + 1, 0) as next_payload_index').where('test_payload_id = ?', payload.id).take.next_payload_index
  end

  test_result = add_named_record(name, create(:test_result, options))

  # Update the payload tests count and new tests count
  payload.tests_count = TestResult.where('test_payload_id = ?', payload.id).count
  payload.new_tests_count = TestResult.where('test_payload_id = ? AND new_test = true', payload.id).count

  payload.save!

  test_description = TestDescription.where(test_id: test.id).where(project_version_id: project_version.id).first

  if !test_description
    description_options = {
      test: test,
      last_runner: runner,
      project_version: project_version,
      active: test_result.active,
      passing: test_result.passed,
      last_run_at: test_result.run_at,
      last_duration: test_result.duration,
      custom_values: test_result.custom_values,
      last_result: test_result
    }

    if category
      description_options[:category] = category
    end

    create(:test_description, description_options)
  else
    test_description.last_runner = runner
    test_description.active = test_result.active
    test_description.passing = test_result.passed
    test_description.last_run_at = test_result.run_at
    test_description.last_duration = test_result.duration
    test_description.custom_values = test_result.custom_values
    test_description.last_result = test_result

    test_description.save!
  end
end

Given /^result (.*) for test "(.+)"(?: is(?: (new) and)?(?: (passing|failing) and)?(?: (active|inactive) and)?)?(?: has category (.+?) and)? was (first )?run(?: (\d*) ((?:day|week)s?) ago)? by (.+?)(?: and took (\d+) second(?:s) to run)? for payload (.+?)(?: at index (\d+))? with version ([^\s]+)$/ do |name,test_name,new_test,passing,active,category_name,first,interval_count,interval,runner_name,execution_time,payload_name,payload_index,project_version|
  create_test_result(name, test_name, new_test, passing, active, category_name, first, interval_count, interval, runner_name, execution_time, payload_name, payload_index, project_version, nil)
end

Given /^result (.*) for test "(.+)"(?: is(?: (new) and)?(?: (passing|failing) and)?(?: (active|inactive) and)?)?(?: has category (.+?) and)? was (first )?run(?: (\d*) ((?:day|week)s?) ago)? by (.+?)(?: and took (\d+) second(?:s) to run)? for payload (.+?)(?: at index (\d+))? with version ([^\s]+) and custom values:/ do |name,test_name,new_test,passing,active,category_name,first,interval_count,interval,runner_name,execution_time,payload_name,payload_index,project_version, custom_values|
  create_test_result(name, test_name, new_test, passing, active, category_name, first, interval_count, interval, runner_name, execution_time, payload_name, payload_index, project_version, custom_values)
end
