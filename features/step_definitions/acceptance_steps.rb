When /^the user visits ([^\s]+)$/ do |path|
  root_url = Rails.application.root_url.to_s.sub(/\/$/, '')
  visit "#{root_url}/#{path.sub(/^\//, '')}"
end

When /^clicks on the register button$/ do
  click_button 'register'
end
