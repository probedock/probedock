module JobHelpers
  include ActiveJob::TestHelper
  JOBS ||= [ ActionMailer::DeliveryJob, ProcessNextTestPayloadJob ]

  def store_jobs_state
    return if @jobs_count
    @jobs_count = enqueued_jobs.length
  end

  def expect_new_jobs counts = {}
    ensure_jobs_state_stored

    errors = []
    new_jobs = new_jobs_since_action

    JOBS.each do |job_class|

      expected_count = counts[job_class] || 0
      matching_jobs = new_jobs.select{ |h| h[:job] == job_class }

      unless matching_jobs.length == expected_count
        errors << "expected to find #{expected_count} #{'job'.pluralize(expected_count)} of class #{job_class} to have been queued, but found #{matching_jobs.length}"
      end
    end

    expect(errors).to be_empty, ->{ "\n#{errors.join("\n")}\n\n" }
  end

  def expect_mailer_job mailer_class, mailer_method, *mailer_args
    ensure_jobs_state_stored

    job_args = [ mailer_class.to_s, mailer_method.to_s, "deliver_now" ] + mailer_args

    matching_job = new_jobs_since_action.find do |h|
      h[:job] == ActionMailer::DeliveryJob && h[:queue] == 'mailers' && ActiveJob::Arguments.deserialize(h[:args]) == job_args
    end

    error_message = lambda do
      m = "\nFound no mailer job for #{mailer_class}##{mailer_method} with arguments #{describe_job_arguments(mailer_args)}"
      m << "\nThe following mailer jobs were found:"
      new_jobs_since_action.select{ |h| h[:queue] == 'mailers' }.each do |h|
        args = ActiveJob::Arguments.deserialize h[:args]
        m << "\n  #{args[0]}##{args[1]} with arguments #{describe_job_arguments(args[3, args.length])}"
      end
      m << "\n\n"
    end

    expect(matching_job).to be_present, error_message
  end

  private

  def ensure_jobs_state_stored
    unless @jobs_count
      raise %/Use JobHelpers#store_jobs_state at the beginning of all "When" step definitions to keep track of background jobs/
    end
  end

  def new_jobs_since_action
    @new_jobs_since_action ||= enqueued_jobs[@jobs_count, enqueued_jobs.length - @jobs_count]
  end

  def describe_job_arguments args
    args.collect{ |arg| arg.respond_to?(:to_global_id) ? arg.to_global_id.to_s : arg.to_s }
  end
end
