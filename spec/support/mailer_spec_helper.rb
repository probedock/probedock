module MailerSpecHelper
  include ActiveJob::TestHelper

  def store_mailer_state
    return if @mailer_state_stored
    @mailer_state_stored = true
    @mailer_jobs_count = enqueued_mailer_jobs.length
    @mailer_deliveries_count = mailer_deliveries_count
  end

  def expect_new_mail_deliveries count = 0
    unless @mailer_state_stored
      raise %/Use MailerSpecHelper#store_mailer_state at the beginning of all "When" step definitions to keep track of sent mails/
    end

    expect(mailer_deliveries_count).to eq(@mailer_deliveries_count), ->{ "Expected number of mail deliveries not to have changed, but it changed by #{mailer_deliveries_count - @mailer_deliveries_count}" }
  end

  private

  def enqueued_mailer_jobs
    enqueued_jobs.select{ |h| h[:job] == ActionMailer::DeliveryJob }
  end

  def mailer_deliveries_count
    ActionMailer::Base.deliveries.size
  end
end
