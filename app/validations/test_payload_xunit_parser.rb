# Converts an xUnit XML report into Probe Dock's JSON payload format.
# It also runs validations at the same time and raises an error if the report is invalid.
class TestPayloadXunitParser

  # Builds a new parser for the specified payload.
  # The duration can also be given if it was specified in a request header
  # (it is optional in an xUnit report, but mandatory for Probe Dock).
  def initialize payload, duration
    @payload = Ox.parse payload
    @duration = duration
  end

  # Returns the JSON version of the xUnit report supplied at construction.
  # Raises a validation error if the report is invalid.
  def parse

    # prepare validation
    @context = Errapi.config.new_context
    @context_proxy = ContextProxy.new self, @context
    @location = Location.new

    parsed = {
      'duration' => @duration.to_i,
      'results' => []
    }

    # check that the top-level tag is a <testsuite>
    location '/testsuite'
    suite = @payload.try(:root) || @payload
    add_error! :missing unless suite.respond_to?(:name) && suite.name == 'testsuite'

    # parse the "time" attribute of the <testsuite>
    # (mandatory if no duration was supplied in a request header)
    check_time_attribute suite, :time, required: !@duration do |value|
      parsed['duration'] = (value * 1000).round
    end

    i = 0
    location '/testsuite/testcase'

    # iterate over <testcase> tags in the <testsuite>
    suite.locate('testcase').each do |test_case|
      relative_location i + 1

      result = {}
      n_errors = @context.errors.length

      # parse the "name" attribute of the <testcase> (mandatory)
      check_string_attribute test_case, :name, limit: false do |value|
        result['n'] = value.length > 255 ? "#{value[0, 252]}..." : value
      end

      # mark the result as inactive if the <testcase> contains any <skipped> tags
      skipped = !test_case.locate('skipped').empty?
      result['v'] = false if skipped

      # mark the result as failed if the <testcase> contains any <failure> tags
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
              n.value
            elsif n.kind_of? String
              n
            else
              nil
            end
          end.compact.join.strip

          memo << [ failure[:type], failure_text ].compact.join("\n")
        end

        result['m'] = messages.join("\n\n").strip
      end

      parsed['results'] << result unless @context.errors.length > n_errors

      @location.pop!
      i += 1
    end

    # check that there is at least one <testcase>
    location '/testsuite/testcase'
    add_error :empty if i <= 0

    # raise an error if anything invalid was found
    check!

    parsed
  end

  # Sets the current XPath location of the validation.
  # Call without an argument to simply get the location.
  #
  #     location '/testsuite'
  #     location                #=> '/testsuite'
  def location absolute = nil
    @location = Location.new absolute if absolute
    @location
  end

  # Sets the XPath location of the validation relative to the current location.
  #
  #     location '/testsuite'
  #     relative_location '/testcase[1]'
  #     location                           #=> '/testsuite/testcase[1]
  def relative_location relative
    @location = @location.relative relative
  end

  private

  def check_string_attribute node, attribute, options = {}
    relative_location "@#{attribute}"
    value = node.attributes[attribute]

    Errapi::Validations::Presence.new.validate value, @context_proxy, location: @location, value_set: node.attributes.key?(attribute)

    limit = options.fetch :limit, 255
    Errapi::Validations::Length.new(maximum: limit).validate value, @context_proxy, location: @location if limit

    yield value if block_given? && !@context.errors?(location: @location)

    @location.pop!
  end

  def check_time_attribute node, attribute, options = {}
    relative_location "@#{attribute}"
    value = node.attributes[attribute]

    Errapi::Validations::Presence.new.validate value, @context_proxy, location: @location, value_set: node.attributes.key?(attribute) if options.fetch :required, true

    add_error :not_numeric if value && value.to_f == 0 && !value.match(/0+(?:\.0+)?(?:e0+)?/) && !@context.errors?(location: @location)

    Errapi::Validations::Numericality.new(greater_than_or_equal_to: 0).validate value.to_f, @context_proxy, location: @location

    yield value.to_f if value && block_given? && !@context.errors?(location: @location)

    @location.pop!
  end

  def add_error reason
    @context_proxy.add_error reason: reason
  end

  def add_error! *args
    add_error *args
    check!
  end

  def check!
    raise Errapi::ValidationFailed.new(@context) if @context.errors?
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

  class Location
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
