Then /nothing should have been added or deleted/ do
  expect_no_change
end

Then /the following changes should have occurred: ((?:[+-]?\d+ [\w ]+)(?:, [+-]?\d+ [\w ]+)*)/ do |changes|

  parsed_changes = changes.split(/, /).inject({}) do |memo,change|

    n, name = change.split(/\s/, 2)
    value = n.sub(/^[+-]/, '').to_i
    value = -value if n.match(/^-/)

    memo[name] = value
    memo
  end

  expect_changes parsed_changes
end
