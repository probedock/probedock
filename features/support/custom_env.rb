ENV['RAILS_ENV'] ||= 'test'
raise "$RAILS_ENV must be test, but it's #{ENV['RAILS_ENV'].inspect}" unless ENV['RAILS_ENV'] == 'test'

if ENV['CAPYBARA_HEADLESS'] && ENV['CAPYBARA_HEADLESS'].match(/^(0|n|no|f|false)$/i)
  Capybara.default_driver = :selenium
else
  require 'capybara/poltergeist'
  Capybara.default_driver = :poltergeist
end
