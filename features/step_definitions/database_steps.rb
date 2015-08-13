Then /there should be no changes to the number of records in the database/ do
  expect_model_count_changes
end

Then /(\w+) (\w+) should no longer exist/ do |type_name,record_name|
  model = named_record record_name
  expect(model.class.where(id: model.id).first).to be_nil
end

Then /there should be a (\w+) in the database corresponding to the response body/ do |model|

  model = begin
    model.singularize.camelize.constantize
  rescue
    raise %/Unknown model "#{model}"/
  end

  raise %/"#{model}" is not an ActiveRecord::Base model/ unless model < ActiveRecord::Base

  send "expect_#{model.name.underscore}", @response_body
end
