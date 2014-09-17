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
class PurgeActionRepresenter < BaseRepresenter

  representation do |purge,*args|
    options = args.last.kind_of?(Hash) ? args.pop : {}

    #link 'self', api_uri(:purge, id: purge.id)

    %w(data_type number_purged remaining_jobs description).each do |name|
      property name.camelize(:lower), purge.send(name) if purge.send(name).present?
    end

    if options[:info]
      property :dataLifespan, purge.data_lifespan
      property :numberRemaining, purge.number_remaining
    end

    %w(created_at completed_at).each do |name|
      property name.camelize(:lower), purge.send(name).to_ms if purge.send(name).present?
    end
  end
end
