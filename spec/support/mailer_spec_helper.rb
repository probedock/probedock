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
