# Copyright (c) 2012-2013 Lotaris SA
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

class Object

  def self.attr_question *names
    names.each do |name|
      define_method("#{name}?"){ instance_variable_get("@#{name}") }
    end
  end
end

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
