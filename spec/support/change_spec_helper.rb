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
