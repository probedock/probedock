module CucumberSpecHelper
  def cucumber_doc_string_to_json doc
    interpolate_json MultiJson.load(doc)
  end

  def cucumber_doc_string_to_xml doc
    Ox.parse doc
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
