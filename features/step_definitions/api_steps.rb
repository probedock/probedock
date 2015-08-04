When /(\w+) authenticates by sending a POST request to \/api\/authentication with Basic password (.*)/ do |user_name,password|

  store_model_counts

  user = User.where(name: user_name).first!
  header 'Authorization', %/Basic #{Base64.strict_encode64("#{user.name}:#{password}")}/

  @response = post '/api/authentication'
  @response_body = MultiJson.load @response.body
end

When /(\w+) sends a PATCH request with the following JSON to (.*):/ do |user_name,api_path,doc|

  store_model_counts

  user = named_record user_name
  header 'Content-Type', 'application/json'
  header 'Authorization', "Bearer #{user.generate_auth_token}"

  body = cucumber_doc_string_to_json doc

  @request_body = body
  @response = patch interpolate_api_url(api_path), MultiJson.dump(@request_body)
  @response_body = MultiJson.load @response.body
end

When /(\w+) sends a POST request with the following JSON to (.*):/ do |user_name,api_path,doc|

  store_model_counts

  user = named_record user_name
  header 'Content-Type', 'application/json'
  header 'Authorization', "Bearer #{user.generate_auth_token}"

  body = cucumber_doc_string_to_json doc

  @request_body = body
  @response = post api_path, MultiJson.dump(@request_body)
  @response_body = MultiJson.load @response.body
end

Then /the response code should be (\d+)/ do |code|
  expect_http_status_code code.to_i
end

Then /the response body should be the following JSON:/ do |doc|
  raise "No request body found" unless @request_body
  raise "No response body found" unless @response_body
  expect_json @response_body, cucumber_doc_string_to_json_expectations(doc)
end

Then /the response should be HTTP (\d+) with the following errors:/ do |code,properties|

  expect_http_status_code code.to_i

  expected_errors = []

  properties.hashes.each do |h|
    expected_error = {}
    expected_error[:path] = h['path'].to_s.strip if h.key? 'path'
    expected_error[:message] = h['message'].to_s.strip if h.key? 'message'
    expected_errors << expected_error
  end

  expect(@response_body).to have_api_errors(expected_errors)
end
