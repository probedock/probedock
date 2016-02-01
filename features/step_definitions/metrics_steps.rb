Given /^assuming reports by day metrics are calculated for (\d+) days by default$/ do |nb_days|
  stub_const('ProbeDock::MetricsApi::DEFAULT_NB_DAYS_FOR_REPORTS', nb_days.to_i)
end

Given /^assuming new tests by day metrics are calculated for (\d+) days by default$/ do |nb_days|
  stub_const('ProbeDock::MetricsApi::DEFAULT_NB_DAYS_FOR_NEW_TESTS', nb_days.to_i)
end

Given /^assuming tests by week metrics are calculated for (\d+) weeks by default$/ do |nb_weeks|
  stub_const('ProbeDock::MetricsApi::DEFAULT_NB_WEEKS_FOR_TESTS', nb_weeks.to_i)
end
