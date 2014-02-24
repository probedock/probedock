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

module ReportHelper

  def report_index results
    {
      tags: results.collect{ |r| r.test_info.tags }.flatten.uniq.sort{ |a,b| a.name.downcase <=> b.name.downcase }.collect{ |t| t.name },
      tickets: results.collect{ |r| r.test_info.tickets }.flatten.uniq.sort{ |a,b| a.name.downcase <=> b.name.downcase }.collect{ |t| t.name }
    }
  end

  def result_card_link result, index, tags, tickets

    klasses = [ (!result.active ? :i : (result.passed ? :p : :f)) ]
    klasses += result.test_info.tags.collect{ |tag| "t#{tags.index(tag.name).to_s(36)}" }
    klasses += result.test_info.tickets.collect{ |ticket| "i#{tickets.index(ticket.name).to_s(36)}" }

    content_tag :a, '', class: klasses.collect{ |k| k.to_s }.join(' '), href: "#r#{index.to_s(36)}"
  end

  def result_details_class result, tags, tickets
    Array.new.tap do |classes|
      classes << (!result.active ? :i : (result.passed ? :p : :f))
      classes.concat result.test_info.tags.collect{ |tag| "t#{tags.index(tag.name).to_s(36)}" }
      classes.concat result.test_info.tickets.collect{ |ticket| "i#{tickets.index(ticket.name).to_s(36)}" }
    end.join ' '
  end

  def result_details_indicator result

    klass, text = if !result.active
      [ 'btn-warning', t('test_runs.report.status.inactive') ]
    elsif result.passed
      [ 'btn-success', t('test_runs.report.status.passed') ]
    else
      [ 'btn-danger', t('test_runs.report.status.failed') ]
    end

    options = {
      type: :button,
      class: "btn pull-right #{klass}",
      disabled: :disabled
    }

    content_tag :button, text, options
  end
end
