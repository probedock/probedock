class UrlValidator < ActiveModel::EachValidator
  # Code from: http://stackoverflow.com/a/9047226
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    begin
      uri = URI.parse(value)
      resp = uri.kind_of?(URI::HTTP)
    rescue URI::InvalidURIError
      resp = false
    end

    unless resp == true
      record.errors[attribute] << (options[:message] || 'is not an url')
    end
  end
end