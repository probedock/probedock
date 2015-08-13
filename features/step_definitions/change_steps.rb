Then /the following changes should have occurred: ((?:[+-]?\d+ [\w ]+)(?:, [+-]?\d+ [\w ]+)*)/ do |changes|

  job_counts = {}
  model_changes = {}

  changes.split(/, /).each do |change|

    n, name = change.split(/\s/, 2)
    value = n.sub(/^[+-]/, '').to_i
    value = -value if n.match(/^-/)

    if name.match(/^mailer +job$/i)
      job_counts[ActionMailer::DeliveryJob] = (job_counts[ActionMailer::DeliveryJob] || 0) + 1
    elsif name.match(/ job$/i)
      job_class = begin
        name.gsub(/ +/, '_').singularize.camelize.constantize
      rescue
        raise %/Unknown job class "#{job_class}" from described change "#{change}"/
      end

      job_counts[job_class] = (job_counts[job_class] || 0) + 1
    else
      model = begin
        name.gsub(/ +/, '_').singularize.camelize.constantize
      rescue
        raise %/Unknown model "#{model}" from described change "#{change}"/
      end

      model_changes[model.name.to_sym] = value
    end
  end

  expect_new_jobs job_counts
  expect_model_count_changes model_changes
  expect_new_mail_deliveries 0
end
