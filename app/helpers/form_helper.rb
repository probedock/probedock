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

module FormHelper

  def render_record_errors record, options = {}
    render partial: 'common/record_errors', locals: options.merge(record: record)
  end

  def record_form_for record, options = {}, &block
    
    if record.new_record?
      options[:method] ||= :post
      options[:url] ||= options[:create_url] || send("#{record.class.name.underscore.pluralize}_path")
    else
      options[:method] ||= :put
      options[:url] ||= options[:update_url] || send("#{record.class.name.underscore}_path", record)
    end

    form_for record, url: options[:url], html: { method: options[:method], class: 'form-horizontal' }, &block
  end
end
