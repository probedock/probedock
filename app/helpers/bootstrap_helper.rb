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
module BootstrapHelper

  def bootstrap_alert options = {}

    type = options[:type]
    raise "Unknown bootstrap alert type #{type}, must be one of #{ALERT_TYPES.join ', '}" unless ALERT_TYPES.include? type

    message = options[:message]
    raise "Message is required" unless message.present?

    title = options[:title]
    dismissable = options.fetch :dismissable, true

    html_classes = [ "alert", "alert-#{type}" ]
    html_classes += %w(alert-dismissable fade in) if dismissable
    html_classes += Array.wrap(options[:class]) if options[:class]

    render partial: 'bootstrap/alert', locals: { html_classes: html_classes, dismissable: dismissable, title: title, message: message }
  end

  private

  ALERT_TYPES = [ :success, :info, :warning, :danger ]
end
