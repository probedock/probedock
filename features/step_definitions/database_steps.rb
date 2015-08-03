Then /there should be no changes to the number of records in the database/ do
  expect_model_count_changes
end

Then /the changes to the number of records in the database should be as follows: ((?:[+-]?\d+ \w+)(?:, [+-]?\d+ \w+)*)/ do |changes|

  changes = changes.split(/, /).inject({}) do |memo,change|

    n, name = change.split(/\s/)

    model = begin
      name.singularize.camelize.constantize
    rescue
      raise %/Unknown model "#{model}" from described change "#{change}"/
    end

    value = n.sub(/^[+-]/, '').to_i
    value = -value if n.match(/^-/)

    memo[model.name.to_sym] = value

    memo
  end

  expect_model_count_changes changes
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
