module CucumberSpecHelper

  # Parses the specified cucumber doc string representing a request body
  # and returns a Hash describing the request data. The contents of the request body
  # are also interpolated to fill in placeholders. JSON and XML data will
  # be parsed so it must be valid.
  #
  # The `data_type` argument must be "XML", "JSON", or a full content type (e.g. "multipart/form-data").
  #
  # The returned Hash provides the following:
  #
  # * `type` - the type of request data (:json, :xml or :custom)
  # * `content_type` - the content type of the request (e.g. "application/json" or "multipart/form-data")
  # * `content` - the parsed and interpolated request body
  # * `serialized_content` - the interpolated request body as a string
  def cucumber_request_data data_type, doc

    # determine type & content type
    type = :custom
    content_type = data_type
    if data_type.match /^(xml|json)$/i
      type = data_type.downcase.to_sym
      content_type = "application/#{type}"
    end

    # parse & interpolate data
    content = if type == :json
      cucumber_doc_string_to_json doc
    elsif type == :xml
      cucumber_doc_string_to_xml doc
    else
      cucumber_doc_string_to_data doc
    end

    # serialize data
    serialized_content = if type == :json
      MultiJson.dump content
    elsif type == :xml
      Ox.dump content
    else
      content
    end

    {
      type: type,
      content_type: content_type,
      content: content,
      serialized_content: serialized_content
    }
  end

  def cucumber_doc_string_to_json doc
    interpolate_json MultiJson.load(doc)
  end

  def cucumber_doc_string_to_xml doc
    Ox.parse doc
  end

  def cucumber_doc_string_to_data doc
    interpolate_content doc
  end

  def headers_for_next_request
    @headers_for_next_request ||= {}
  end

  def headers_for_all_requests
    @headers_for_all_requests ||= {}
  end

  def apply_headers_for_current_request!
    h = headers_for_all_requests.merge(headers_for_next_request)

    h.each do |k,v|
      header k, v
    end

    @headers_for_next_request = {}

    h
  end
end
