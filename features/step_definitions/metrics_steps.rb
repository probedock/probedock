Given /^assuming reports by day metrics are calculated for (\d+) days by default$/ do |nb_days|
  stub_const('ProbeDock::MetricsApi::DEFAULT_NB_DAYS_FOR_REPORTS', nb_days.to_i)
end
