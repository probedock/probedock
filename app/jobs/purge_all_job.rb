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
class PurgeAllJob
  @queue = :purge

  include RoxHook
  on('api:payload'){ |payload| enqueue_throttled }

  def self.enqueue_throttled
    available = $redis.set 'purge:lock', Time.now.to_i, ex: 86400, nx: true
    Resque.enqueue self if available
    available
  end

  def self.perform
    PurgeAction::DATA_TYPES.each do |data_type|
      job_class = PurgeAction.job_class data_type
      if job_class.number_remaining >= 1
        PurgeAction.new(data_type: data_type).save!
      end
    end
  end
end
