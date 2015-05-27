# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of Probe Dock.
#
# Probe Dock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Probe Dock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.
module RedisHelpers

  def number_of_redis_calls type = nil
    watch_redis_calls
    type ? @redis_calls[type].to_i : @redis_calls.inject(0){ |memo,(k,v)| memo + v }
  end

  # This assumes that Resque.size uses llen("queue:#{name}") to determine the size of a queue.
  # It might have to be updated if the Resque implementation changes.
  def fill_resque_queue name, *args
    Resque.redis.lpush "queue:#{name}", args
  end

  def stub_and_call_original object, method, &block
    original = object.method method
    allow(object).to receive(method) do |*args,&run_block|
      block.call object
      original.call *args, &run_block
    end
  end

  private

  # This assumes that normal Redis calls go through the :call method of its client,
  # and that :multi and :pipelined don't. It might have to be updated if the Redis
  # implementation changes.
  def watch_redis_calls
    return if @redis_calls
    @redis_calls = { single: 0, multi: 0, pipelined: 0 }
    stub_and_call_original($redis.client, :call){ @redis_calls[:single] += 1 }
    stub_and_call_original($redis, :multi){ @redis_calls[:multi] += 1 }
    stub_and_call_original($redis, :pipelined){ @redis_calls[:pipelined] += 1 }
  end
end
