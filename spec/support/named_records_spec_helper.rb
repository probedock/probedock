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
module NamedRecordsSpecHelper
  def add_named_record(name, record)
    @named_records ||= {}
    key = NamedRecordKey.new(name, record)
    raise "A named record already exists for #{key}" if @named_records[key]
    @named_records[key] = record
  end

  def named_record(name)
    records = @named_records.select do |key, value|
      key.name == name
    end

    raise "Unknown named record #{name.inspect}" if records.length == 0
    raise "More than one named record #{name.inspect}" if records.length > 1

    records.values.first
  end

  def named_record_by_type(name, type)
    key = NamedRecordKey.new(name, type)
    record = @named_records.try(:[], key)
    raise "Unknown named record #{key}" unless record
    record
  end

  class NamedRecordKey
    attr_reader :name, :type

    def initialize(name, type)
      @name = name
      if type.is_a?(String)
        @type = type
      elsif type.is_a?(Class)
        @type = type.name
      else
        @type = type.class.name
      end
    end

    def eql?(named_record_key)
      name == named_record_key.name && type == named_record_key.type
    end

    def hash
      name.hash + type.hash
    end

    def to_s
      "name: #{name}, type: #{type}"
    end
  end
end
