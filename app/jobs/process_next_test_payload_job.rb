# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
require 'resque/plugins/workers/lock'

class ProcessNextTestPayloadJob
  extend Resque::Plugins::Workers::Lock

  @queue = :api

  def self.perform

    payload = TestPayload.waiting_for_processing.includes(:runner).first
    payload.start_processing!

    begin
      TestPayloadProcessing::ProcessPayload.new payload
    rescue
      payload.fail_processing!
    end
  end

  # resque-workers-lock: lock workers to prevent concurrency
  def self.lock_workers *args
    name # the same lock (class name) is used for all workers
  end
end
