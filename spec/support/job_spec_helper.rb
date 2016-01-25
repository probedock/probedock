# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
module JobSpecHelper
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

      matching_jobs = if queue_name = job_class.instance_variable_get(:@queue)
        ResqueSpec.queue_by_name(queue_name).select{ |h| h[:class].to_s == job_class.to_s }
      else
        new_jobs_since_action.select{ |h| h[:job].to_s == job_class.to_s }
      end

      unless matching_jobs.length == expected_count
        errors << "expected to find #{expected_count} #{'job'.pluralize(expected_count)} of class #{job_class} queued, but found #{matching_jobs.length}"
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
      raise %/Use JobSpecHelper#store_jobs_state at the beginning of all "When" step definitions to keep track of background jobs/
    end
  end

  def new_jobs_since_action
    @new_jobs_since_action ||= enqueued_jobs[@jobs_count, enqueued_jobs.length - @jobs_count]
  end

  def describe_job_arguments args
    args.collect{ |arg| arg.respond_to?(:to_global_id) ? arg.to_global_id.to_s : arg.to_s }
  end
end
