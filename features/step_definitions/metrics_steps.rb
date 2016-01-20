Given /^assuming (\d+) days is set to retrieve the reports by day$/ do |nb_days|
  stub_const('ProbeDock::MetricsApi::DEFAULT_NB_DAYS_FOR_REPORTS', nb_days.to_i)
end
