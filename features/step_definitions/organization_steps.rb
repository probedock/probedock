Given /organization (\w+) exists/ do |name|
  options = { name: name.downcase }
  options[:display_name] = name if name != options[:name]
  add_named_record name, create(:organization, options)
end

Given /user (\w+) who is an admin for (\w+) exists/ do |user_name,organization_name|
  org = Organization.where(name: organization_name.downcase).first!
  add_named_record user_name, create(:org_admin, name: user_name, organization: org)
end

When /(\w+) POSTs JSON to (.*) with:/ do |user_name,api_path,properties|

  user = User.where(name: user_name).first!
  header 'Content-Type', 'application/json'
  header 'Authorization', "Bearer #{user.generate_auth_token}"

  body = {}

  properties.hashes.each do |h|
    name, value = h['property'], h['value']

    if m = value.match(/^idOf: (.*)$/)
      body[name] = named_record(m[1]).api_id
    else
      body[name] = if value == 'true'
        true
      elsif value == 'false'
        false
      else
        value
      end
    end
  end

  @request_body = body
  @response = post api_path, MultiJson.dump(@request_body)
  @response_body = MultiJson.load @response.body
end

Then /the response code should be (\d+)/ do |code|
  expect(@response.status).to eq(code.to_i), ->{
    msg = ""
    msg << "\nexpected #{http_status_code_description(code)}"
    msg << "\n     got #{http_status_code_description(@response.status)}"
    msg << "\n\n#{JSON.pretty_generate MultiJson.load(@response.body)}\n\n"
  }
end

Then /the response body should include in addition to the request body:/ do |properties|

  expected = @request_body.dup

  properties.hashes.each do |h|
    name, value = h['property'], h['value']

    expected[name] = if value == '@alphanumeric'
      /\A[a-z0-9]+\Z/
    elsif value == '@iso8601'
      /.*/ # TODO: validate ISO 8601 dates
    elsif value == 'true'
      true
    elsif value == 'false'
      false
    elsif value == '[]'
      []
    else
      value
    end
  end

  expect_json @response_body, expected
end
