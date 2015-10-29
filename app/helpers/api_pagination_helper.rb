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

# Utility methods to return paginated data, available to all API classes mounted in `ProbeDock::API`.
module ApiPaginationHelper

  # Returns a paginated version of the specified relation.
  # If your query can be filtered, you should apply your filters in a block that
  # you pass to this method. This block should return the filtered relation.
  # This will allow the pagination mechanism to tell the client how many records
  # are available in total, and how many are available with your filters applied.
  #
  #     rel = Project.where some: condition
  #
  #     rel = paginated rel
  #       if params[:organizationId]
  #         rel = rel.where organizationId: params[:organizationId]
  #       end
  #
  #       if true_flag? :foo
  #         rel = rel.where foo: 'bar'
  #       end
  #
  #       rel
  #     end
  #
  #     results = rel.to_a
  #
  # ## Options
  #
  # * `pageSize` - `int` - the number of records to retrieve (defaults to 15)
  # * `page` - `int` - the page at which to start (starts at 1, defaults to 1)
  #
  # ## Headers set by this method
  #
  # * `X-Pagination-Page` - `int` - the selected page
  # * `X-Pagination-Page-Size` - `int` - the selected page size
  # * `X-Pagination-Total` - `int` - the total number of available records (regardless of filters)
  # * `X-Pagination-Filtered-Total` - `int` - the number of available records with filters applied (only given if filters have been applied)
  #
  # ## Caveats
  #
  # The calculation of the filtered total is done with a simple count.
  # This works for simple requests, but if you use a GROUP BY clause, it might not
  # yield the correct result.
  #
  # If necessary, set the `@pagination_filtered_count` variable in the block.
  # Its value will be used for the filtered count. You can also set the `@pagination_filtered_count_rel`
  # variable, which should be a relation that will yield the correct count when calling `#count`.
  #
  #     rel = User
  #
  #     rel = paginated rel do
  #       if params[:organizationId].present?
  #         rel = rel.joins(memberships: :organization).where('organizations.api_id = ?', params[:organizationId].to_s)
  #         rel = rel.group 'users.id'
  #       end
  #
  #       @pagination_filtered_count = rel.count 'distinct users.id'
  #
  #       rel
  #     end
  def paginated rel, options = {}

    # Determine the limit based on the :pageSize option.
    # Default to 15 if invalid.
    limit = params[:pageSize].to_i
    limit = options.fetch :default_page_size, 15 if limit < 1

    # Determine the offset based on the :page (and :pageSize) options.
    # Defaults to 0 if invalid.
    page = params[:page].to_i
    offset = (page - 1) * limit
    if offset < 1
      page = 1
      offset = 0
    end

    # Set the page and page size headers.
    header 'X-Pagination-Page', page.to_s
    header 'X-Pagination-Page-Size', limit.to_s

    # Count total records and set the total header.
    header 'X-Pagination-Total', rel.count.to_s

    # Apply supplied filters (if any).
    filtered_rel = if block_given?
      yield rel
    else
      rel
    end

    # Count filtered records and set the filtered total header.
    if filtered_rel != rel

      filtered_count = if @pagination_filtered_count
        @pagination_filtered_count
      else
        (@pagination_filtered_count_rel || filtered_rel).count
      end

      header 'X-Pagination-Filtered-Total', filtered_count.to_s
    end

    # Apply the offset and limit.
    filtered_rel.offset(offset).limit(limit)
  end
end
