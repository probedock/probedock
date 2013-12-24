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

class TestSearch

  def self.options params, options = {}

    except = Array.wrap(options[:except] || [])

    q = TestInfo.standard
    return { base: q, base_count: q } if params.blank?

    if !except.include?(:status)
      case params[:status].try(:to_s).try(:strip).try(:downcase)
      when 'failing'
        q = TestInfo.failing
      when 'inactive'
        q = TestInfo.inactive
      when 'outdated'
        q = TestInfo.outdated
      when 'deprecated'
        q = TestInfo.deprecated
      end
    end

    if !except.include?(:projects)
      projects = params[:projects].kind_of?(Array) ? params[:projects].collect(&:to_s).select(&:present?) : nil
      q = q.joins(:project).where('projects.name IN (?)', projects) if projects.present?
    end

    if !except.include?(:categories)
      categories = params[:categories].kind_of?(Array) ? params[:categories].collect(&:to_s) : []
      conditions, values = [], []
      conditions << 'test_infos.category_id IS NULL' if categories.delete ' '
      if categories.present?
        q = q.joins 'LEFT OUTER JOIN categories ON test_infos.category_id = categories.id'
        conditions << 'categories.name IN (?)'
        values << categories
      end
      if conditions.present?
        q = q.where *values.unshift("(#{conditions.collect{ |c| "(#{c})" }.join ' OR '})")
      end
    end

    users_join = false
    if !except.include?(:authors)
      authors = params[:authors].kind_of?(Array) ? params[:authors].collect(&:to_s).select(&:present?) : nil
      q = q.joins(:author).where('users.name IN (?)', authors) if authors.present?
      users_join ||= authors.present?
    end

    if !except.include?(:breakers)
      breakers = params[:breakers].kind_of?(Array) ? params[:breakers].collect(&:to_s).select(&:present?) : nil
      if breakers.present?
        table_alias = users_join ? :runners_test_results : :users
        q = q.joins(effective_result: :runner).where("test_infos.active = ? AND test_infos.passing = ? AND #{table_alias}.name IN (?)", true, false, breakers) if breakers.present?
        users_join = true
      end
    end

    cq = q

    if !except.include?(:tags)
      tags = params[:tags].kind_of?(Array) ? params[:tags].collect(&:to_s).select(&:present?) : nil
      if tags.present?
        q = q.group('test_infos.id').joins(:tags).where('tags.name IN (?)', tags)
        cq = cq.select('distinct test_infos.id').joins(:tags).where('tags.name IN (?)', tags)
      end
    end

    {
      base: q,
      base_count: cq
    }
  end

  def self.config params, options = {}

    except = Array.wrap(options[:except] || [])

    data = Hash.new.tap do |h|
      h[:statuses] = [ :failing, :inactive, :outdated, :deprecated ] if !except.include?(:statuses)
      h[:projects] = Project.pluck(:name).sort if !except.include?(:projects)
      h[:tags] = Tag.pluck(:name).sort if !except.include?(:tags)
      h[:categories] = Category.pluck(:name).sort if !except.include?(:categories)
      h[:authors] = User.all.to_a.collect(&:to_client_hash) if !except.include?(:authors)
      h[:breakers] = h[:authors] || User.all.to_a.collect(&:to_client_hash) if !except.include?(:breakers)
    end

    config = { data: data }

    if !except.include?(:current)
      config[:current] = {
        tags: params[:tags].kind_of?(Array) ? params[:tags].collect(&:to_s).select(&:present?) : nil,
        projects: params[:projects].kind_of?(Array) ? params[:projects].collect(&:to_s).select(&:present?) : nil,
        authors: params[:authors].kind_of?(Array) ? params[:authors].collect(&:to_s).select(&:present?) : nil,
        breakers: params[:breakers].kind_of?(Array) ? params[:breakers].collect(&:to_s).select(&:present?) : nil,
        categories: params[:categories].kind_of?(Array) ? params[:categories].collect(&:to_s) : nil,
        status: params[:status].try(:to_s).try(:strip).try(:downcase)
      }.select{ |k,v| v.present? }
    end

    config.select{ |k,v| v.present? }
  end
end
