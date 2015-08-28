module ApiPaginationHelper
  def paginated rel, options = {}
    limit = params[:pageSize].to_i
    limit = options.fetch :default_page_size, 15 if limit < 1

    page = params[:page].to_i
    offset = (page - 1) * limit
    if offset < 1
      page = 1
      offset = 0
    end

    header 'X-Pagination-Page', page.to_s
    header 'X-Pagination-Page-Size', limit.to_s
    header 'X-Pagination-Total', rel.count.to_s

    filtered_rel = if block_given?
      yield rel
    else
      rel
    end

    if filtered_rel != rel

      filtered_count = if @pagination_filtered_count
        @pagination_filtered_count
      else
        (@pagination_filtered_count_rel || filtered_rel).count
      end

      header 'X-Pagination-Filtered-Total', filtered_count.to_s
    end

    filtered_rel.offset(offset).limit(limit)
  end
end
