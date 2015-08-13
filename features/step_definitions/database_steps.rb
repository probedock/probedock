Then /(\w+) (\w+) should no longer exist/ do |type_name,record_name|
  model = named_record record_name
  expect(model.class.where(id: model.id).first).to be_nil
end

Then /the following ([\w ]+) should be in the database/ do |model,doc|

  model = begin
    model.gsub(/ +/, '_').singularize.camelize.constantize
  rescue
    raise %/Unknown model "#{model}"/
  end

  raise %/"#{model}" is not an ActiveRecord::Base model/ unless model < ActiveRecord::Base

  send "expect_#{model.name.underscore}", YAML.load(doc)
end
