module CucumberSpecHelper

  # Parses the specified cucumber doc string representing a request body
  # and returns an object describing the request data. The contents of the
  # request body are also interpolated to fill in placeholders. JSON and XML
  # data will be parsed so it must be valid.
  #
  # The `data_type` argument must be "XML", "JSON", or a full content type (e.g. "multipart/form-data").
  #
  # The returned object has the following attributes:
  #
  # * `type` - the type of request data (:json, :xml or :custom)
  # * `content_type` - the content type of the request (e.g. "application/json" or "multipart/form-data")
  # * `content` - the parsed and interpolated request body
  # * `serialized_content` - the interpolated request body as a string
  #
  #     request_data = cucumber_request_data 'JSON', doc_string
  #     request_data.type                 #=> :json
  #     request_data.content_type         #=> "application/json"
  #     request_data.content              #=> parsed JSON data
  #     request_data.serialized_content   #=> JSON data as string
  def cucumber_request_data data_type, doc

    # determine type & content type
    type = :custom
    content_type = data_type
    if data_type.match /^(xml|json)$/i
      type = data_type.downcase.to_sym
      content_type = "application/#{type}"
    else
      matched_type = data_type.match(/(?:^application\/|.*\+)(xml|json)$/)
      unless matched_type.nil?
        type = matched_type[1].downcase.to_sym
      end
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

    OpenStruct.new({
      type: type,
      content_type: content_type,
      content: content,
      serialized_content: serialized_content
    })
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
