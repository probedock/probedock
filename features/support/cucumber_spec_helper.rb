module CucumberSpecHelper
  def cucumber_doc_string_to_json doc
    interpolate_json MultiJson.load(doc)
  end
end
