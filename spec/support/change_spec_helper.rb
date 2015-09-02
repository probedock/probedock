module ChangeSpecHelper
  def store_preaction_state
    store_jobs_state
    store_mailer_state
    store_model_counts
  end

  def expect_no_change
    expect_new_jobs
    expect_model_count_changes
    expect_new_mail_deliveries 0
  end

  def expect_changes changes
    job_counts = {}
    model_changes = {}

    changes.each_pair do |name,value|
      name = name.to_s

      if name.match(/^mailer +job$/i)
        job_counts[ActionMailer::DeliveryJob] = (job_counts[ActionMailer::DeliveryJob] || 0) + value
      elsif name.match(/ job$/i)
        job_class = begin
          name.gsub(/ +/, '_').singularize.camelize.constantize
        rescue
          raise %/Unknown job class "#{job_class}" from described change "#{change}"/
        end

        job_counts[job_class] = (job_counts[job_class] || 0) + value
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
end
