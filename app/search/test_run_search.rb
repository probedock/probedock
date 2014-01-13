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

class TestRunSearch

  def self.options params, options = {}

    except = Array.wrap(options[:except] || [])

    q = TestRun
    return { base: q, base_count: q } if params.blank?

    if !except.include?(:groups)
      groups = params[:groups].kind_of?(Array) ? params[:groups].collect(&:to_s).select(&:present?) : nil
      q = q.where('test_runs.group IN (?)', groups) if groups.present?
    end

    if !except.include?(:runners)
      runners = params[:runners].kind_of?(Array) ? params[:runners].collect(&:to_s).select(&:present?) : nil
      q = q.joins(:runner).where('users.name IN (?)', runners) if runners.present?
    end

    { base: q, base_count: q }
  end

  def self.config params, options = {}

    except = Array.wrap(options[:except] || [])

    data = Hash.new.tap do |h|
      h[:groups] = TestRun.groups if !except.include?(:groups)
      h[:runners] = User.all.to_a.collect(&:to_client_hash) if !except.include?(:runners)
    end

    config = { data: data }

    if !except.include?(:current)
      config[:current] = {
        groups: params[:groups].kind_of?(Array) ? params[:groups].collect(&:to_s).select(&:present?) : nil,
        runners: params[:runners].kind_of?(Array) ? params[:runners].collect(&:to_s).select(&:present?) : nil
      }.select{ |k,v| v.present? }
    end

    config.select{ |k,v| v.present? }
  end
end
