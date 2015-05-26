# Copyright (c) 2015 Probe Dock
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
class Array

  def deep_stringify_keys!
    each{ |v| v.deep_stringify_keys! if v.respond_to?(:deep_stringify_keys!) }
  end
end

class Hash

  def deep_stringify_keys!
    stringify_keys!
    each_value{ |v| v.deep_stringify_keys! if v.respond_to?(:deep_stringify_keys!) }
  end

  def pick! *args
    keep_if{ |k,v| args.include? k }
  end

  def pick *args
    dup.pick! *args
  end

  def omit! *args
    delete_if{ |k,v| args.include? k }
  end

  def omit *args
    dup.omit! *args
  end
end

class ActiveSupport::HashWithIndifferentAccess < Hash

  def pick! *args
    args = args.collect{ |a| convert_key a }
    keep_if{ |k,v| args.include? k.to_s }
  end

  def omit! *args
    args = args.collect{ |a| convert_key a }
    delete_if{ |k,v| args.include? k.to_s }
  end
end

class Time

  def to_ms
    (to_f * 1000).floor
  end

  def ms_from time
    ((to_f - time.to_f) * 1000).round
  end
end
