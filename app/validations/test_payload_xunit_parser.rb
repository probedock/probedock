# Converts an xUnit XML report into Probe Dock's JSON payload format.
# It also runs validations at the same time and raises an error if the report is invalid.
class TestPayloadXunitParser
  attr_reader :location

  # Builds a new parser for the specified payload.
  # The duration can also be given if it was specified in a request header
  # (it is optional in an xUnit report, but mandatory for Probe Dock).
  def initialize body, headers = {}
    @body = body
    @headers = headers
  end

  # Returns the JSON version of the xUnit report supplied at construction.
  # Raises a validation error if the report is invalid.
  def parse

    # prepare validation
    @context = Errapi.config.new_context
    @context_proxy = ContextProxy.new self, @context

    parsed = {
      'results' => []
    }

    parse_headers parsed
    parse_body parsed

    # raise an error if anything invalid was found
    raise Errapi::ValidationFailed.new(@context) if @context.errors?

    parsed
  end

  # Parses and validates the test payload's project, duration and report information from request headers.
  def parse_headers parsed

    # get the project from headers (mandatory)
    parsed['projectId'] = @headers['Probe-Dock-Project-Id']
    @location = HeaderLocation.new 'Probe-Dock-Project-Id'
    Errapi::Validations::Presence.new.validate parsed['projectId'], @context_proxy, location: @location, value_set: @headers.key?('Probe-Dock-Project-Id')

    # get the project version from headers (mandatory)
    parsed['version'] = @headers['Probe-Dock-Project-Version']
    @location = HeaderLocation.new 'Probe-Dock-Project-Version'
    Errapi::Validations::Presence.new.validate parsed['version'], @context_proxy, location: @location, value_set: @headers.key?('Probe-Dock-Project-Version')
    Errapi::Validations::Length.new(maximum: 100).validate parsed['version'], @context_proxy, location: @location if parsed['version']

    # get the category from headers (optional)
    if @category = @headers['Probe-Dock-Category']
      @location = HeaderLocation.new 'Probe-Dock-Category'
      Errapi::Validations::Presence.new.validate @category, @context_proxy, location: @location
      Errapi::Validations::Length.new(maximum: 50).validate @category, @context_proxy, location: @location
    end

    # get the duration from headers (optional)
    @duration = @headers['Probe-Dock-Duration']
    # TODO: properly validate the Probe-Dock-Duration header
    parsed['duration'] = @duration.to_i if @duration && @duration.to_i > 0

    # get the report UID from headers (optional)
    @uid = @headers['Probe-Dock-Test-Report-Uid']
    parsed['reports'] = [ { 'uid' => @uid } ] if @uid
  end

  # Parses and validates the test payload's results from the XML request body.
  def parse_body parsed

    # parse the XML and get the root tag
    payload = Ox.parse @body
    root = payload.try(:root) || payload

    # find the <testsuite> tags (either one at the top level or several in a <testsuites> tag)
    suites = case root.name
    when 'testsuites' # the top-level tag is <testsuites>
      @location = XPathLocation.new '/testsuites/testsuite'
      root.locate 'testsuite'
    when 'testsuite' # the top-level tag is <testsuite>
      @location = XPathLocation.new '/testsuite'
      [ root ]
    else # no <testsuites> or <testsuite> tag found at the top level
      @location = XPathLocation.new '/testsuite'
      []
    end

    # check that there is at least one <testsuite>
    Errapi::Validations::Presence.new.validate suites, @context_proxy, location: @location, value_set: suites.present?

    # parse and validate each <testsuite>
    suites.each.with_index do |suite,i|
      relative_location! i + 1 if root.name == 'testsuites'
      parse_test_suite suite, parsed
      @location.pop! if root.name == 'testsuites'
    end
  end

  # Parses the test results in a <testsuite> tag.
  def parse_test_suite suite, parsed

    # parse the "timestamp" attribute of the <testsuite>
    if suite.attributes.key? :timestamp
      ended_at = suite.attributes[:timestamp]
      parsed_ended_at = Time.parse ended_at rescue nil

      # save the latest valid timestamp found (in case there are multiple <testsuite> tags)
      if parsed_ended_at && (!@last_ended_at || parsed_ended_at > @last_ended_at)
        parsed['endedAt'] = ended_at # put the raw version into the payload
        @last_ended_at = parsed_ended_at
      end
    end

    # parse the "time" attribute of the <testsuite>
    # (if no duration was supplied in a request header)
    unless @duration
      check_time_attribute suite, :time, required: !@duration do |value|
        add_duration parsed, (value * 1000).round
      end
    end

    i = 0
    relative_location! '/testcase'

    # check that there is at least one <testcase>
    test_cases = suite.locate 'testcase'
    Errapi::Validations::Presence.new.validate test_cases, @context_proxy, location: @location, value_set: test_cases.present?

    # iterate over <testcase> tags in the <testsuite>
    test_cases.each do |test_case|
      relative_location! i + 1

      result = {}
      n_errors = @context.errors.length

      # add the category if present
      result['c'] = @category if @category

      # parse the "name" attribute of the <testcase> (mandatory)
      check_string_attribute test_case, :name, limit: false do |value|
        normalized_value = value.strip.underscore.humanize
        result['n'] = normalized_value.length > 255 ? "#{normalized_value[0, 252]}..." : normalized_value
      end

      # mark the result as inactive if the <testcase> contains any <skipped> tags (optional)
      skipped = !test_case.locate('skipped').empty?
      result['v'] = false if skipped

      # mark the result as failed if the <testcase> contains any <failure> tags (optional)
      failures = test_case.locate('failure')
      result['p'] = false unless failures.empty?

      # parse the "time" attribute of the <testcase> (mandatory)
      check_time_attribute test_case, :time, required: !skipped do |value|
        result['d'] = (value * 1000).round
      end

      # if failures are present, collect their type and text for the test result message
      if failures.present?
        messages = failures.inject([]) do |memo,failure|

          failure_text = failure.nodes.collect do |n|
            if n.respond_to? :value
              n.value # extract text from Ox CDATA tag
            elsif n.kind_of? String
              n # Ox parses text nodes directly as strings
            else
              nil # ignore other content
            end
          end.compact.join.strip

          # concatenate the "type" attribute of the <failure> tag (if present) with its text contents
          memo << [ failure[:type], failure_text ].compact.join("\n")
        end

        result['m'] = messages.join("\n\n").strip
      end

      parsed['results'] << result unless @context.errors.length > n_errors

      @location.pop!
      i += 1
    end

    @location.pop!
  end

  # Sets the location of the validation relative to the current location.
  #
  #     @location = XPathLocation.new '/testsuite'
  #     relative_location! '/testcase[1]'
  #     @location                                    #=> '/testsuite/testcase[1]
  def relative_location! relative
    @location = @location.relative relative
  end

  private

  def add_duration parsed, duration
    parsed['duration'] ||= 0
    parsed['duration'] += duration
  end

  # Parses and validates the string value of a required XML attribute.
  # A max length validation of 255 is applied by default, which can be configured
  # by passing the :limit option (set to false to disable the limit).
  # Pass a block to receive the parsed value (only if it is valid).
  #
  #     node = Ox.parse '<tag foo="bar" />'
  #
  #     check_string_attribute node, :foo do |value|
  #       value   #=> "bar"
  #     end
  #
  #     check_string_attribute node, :foo, limit: 2 do |value|
  #       # block not called, validation error added to the context
  #     end
  #
  #     check_string_attribute node, :foo, limit: false do |value|
  #       value   #=> "bar"
  #     end
  def check_string_attribute node, attribute, options = {}
    relative_location! "@#{attribute}"
    value = node.attributes[attribute]

    # ensure the attribute is present
    Errapi::Validations::Presence.new.validate value, @context_proxy, location: @location, value_set: node.attributes.key?(attribute)

    # check the length limit (unless disabled)
    limit = options.fetch :limit, 255
    Errapi::Validations::Length.new(maximum: limit).validate value, @context_proxy, location: @location if limit

    # yield the value if valid
    yield value if block_given? && !@context.errors?(location: @location)

    @location.pop!
  end

  # Parses and validates the value of an XML attribute representing a time (decimal number).
  # The present of the attribute is required by default but this can be disabled by setting the :required option to false.
  # Also validates that the number is greater than or equal to 0.
  # Pass a block to receive the parsed value (only if it is valid).
  #
  #     node = Ox.parse '<tag foo="1.23" />'
  #
  #     check_time_attribute node, :foo do |value|
  #       value   #=> 1.23
  #     end
  #
  #     node = Ox.parse '<tag foo="abc" />'
  #
  #     check_time_attribute node, :foo do |value|
  #       # block not called, validation error added to the context
  #     end
  #
  #     node = Ox.parse '<tag />'
  #
  #     check_time_attribute node, :foo, required: false do |value|
  #       # block not called, no validation error
  #     end
  def check_time_attribute node, attribute, options = {}
    relative_location! "@#{attribute}"
    value = node.attributes[attribute]

    # ensure the attribute is present (unless disabled)
    Errapi::Validations::Presence.new.validate value, @context_proxy, location: @location, value_set: node.attributes.key?(attribute) if options.fetch :required, true

    # ensure the time string represents a number
    add_error :not_numeric if value && value.to_f == 0 && !value.match(/0+(?:\.0+)?(?:e0+)?/) && !@context.errors?(location: @location)

    # ensure the time value is within bounds
    Errapi::Validations::Numericality.new(greater_than_or_equal_to: 0).validate value.to_f, @context_proxy, location: @location

    # yield the value if present and valid
    yield value.to_f if value && block_given? && !@context.errors?(location: @location)

    @location.pop!
  end

  # Adds an error to the validation context.
  def add_error reason
    @context_proxy.add_error reason: reason
  end

  class ContextProxy
    def initialize parser, context
      @parser = parser
      @context = context
    end

    def add_error options = {}, &block

      additional_error_options = {
        location: @parser.location.dup
      }

      @context.add_error additional_error_options.merge(options), &block
    end

    def errors? *args, &block
      @context.errors? *args, &block
    end
  end

  class HeaderLocation
    def initialize header
      @location = header.to_s
    end

    def location_type
      :header
    end

    def serialize
      @location
    end

    def === location
      @location.to_s == location.to_s
    end

    def to_s
      @location
    end
  end

  class XPathLocation
    def initialize location = nil
      @location = location.nil? ? '' : "/#{location.to_s.sub(/^\//, '').sub(/\/$/, '')}"
    end

    def relative parts
      if @location.nil?
        self.class.new parts
      elsif parts.kind_of? Integer
        self.class.new "#{@location}[#{parts}]"
      else
        self.class.new "#{@location}/#{parts.to_s.sub(/^\//, '').sub(/\/$/, '')}"
      end
    end

    def pop!
      @location = @location.sub /(?:\[\d+\]|\/@?[a-z0-9\-\_]+)$/i, ''
    end

    def location_type
      :xpath
    end

    def serialize
      @location
    end

    def === location
      @location.to_s == location.to_s
    end

    def to_s
      @location
    end
  end
end
