# Copyright (c) 2015 ProbeDock
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
module ReportsHelper
  class Template
    def initialize categories, tags, tickets
      @categories = categories
      @tags = tags
      @tickets = tickets
    end

    def report_health_test_result_classes result
      classes = []

      classes << 'nt' if result.new_test?

      if result.active?
        classes << (result.passed? ? 'p' : 'f')
      else
        classes << 'i'
      end

      if result.category.present?
        i = @categories.index result.category.name
        classes << "c-#{i.to_s(36)}" if i
      end

      result.tags.each do |tag|
        i = @tags.index tag.name
        classes << "t-#{i.to_s(36)}" if i
      end

      result.tickets.each do |ticket|
        i = @tickets.index ticket.name
        classes << "i-#{i.to_s(36)}" if i
      end

      classes.empty? ? nil : classes.join(' ')
    end
  end
end
