module CucumberSpecHelper
  def cucumber_request_data data_type, doc
    type = :custom
    content_type = data_type

    if data_type.match /^(xml|json)$/i
      type = data_type.downcase.to_sym
      content_type = "application/#{type}"
    end

    content = if type == :json
      cucumber_doc_string_to_json doc
    elsif type == :xml
      cucumber_doc_string_to_xml doc
    else
      cucumber_doc_string_to_data doc
    end

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
