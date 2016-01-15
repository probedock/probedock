class TestPayloadXmlParser

  def initialize payload
    @payload = payload
    @context = Errapi.config.new_context
    @context_proxy = ContextProxy.new self, @context
    @location = Location.new
  end

  def parse

    parsed = {
      'results' => []
    )

    location '/testsuite'
    suite = @payload.locate('testsuite').first

    add_error! :missing unless suite

    check_time_attribute suite, :time do |value|
      parsed['duration'] = (value * 1000).round
    end

    i = 0
    location '/testsuite/testcase'

    @payload.locate('testsuite/testcase').each do |test_case|
      relative_location i

      result = {}
      n_errors = @context.errors.length

      check_time_attribute test_case, :time do |value|
        result['d'] = (value * 1000).round
      end

      check_string_attribute test_case, :name, limit: false do |value|
        result['n'] = value.length > 255 ? "#{value[0, 252]}..." : value
      end

      skipped = !test_case.locate('skipped').empty?
      result['v'] = false if skipped

      failures = test_case.locate('failure')
      result['p'] = false unless failures.empty?

      if failures.present?
        puts failures.inspect
        messages = failures.inject([]) do |memo,failure|

          message = failure.nodes.collect do |n|
            if n.respond_to? :value
              n.value
            elsif n.kind_of? String
              n
            else
              nil
            end
          end.compact.join.strip

          failure_type = failure.type
          message = "#{failure_type}:\n#{message}"

          memo << message
        end

        result['m'] = messages.join("\n\n").strip
      end

      parsed['results'] << result unless @context.errors.length > n_errors

      @location.pop!
      i += 1
    end

    location '/testsuite/testcase'
    add_error :empty if i <= 0

    check!

    parsed
  end

  def location absolute = nil
    @location = Location.new absolute if absolute
    @location
  end

  private

  def check_string_attribute node, attribute, options = {}
    relative_location "@#{attribute}"

    unless node.respond_to? attribute
      add_error :missing
      @location.pop!
      return
    end

    value = node[attribute]

    limit = options.fetch :limit, 255
    Errapi::Validations::Length.new(maximum: limit).validate value, @context_proxy, location: @location if limit

    yield value if block_given? && !@context.errors?(location: @location)

    @location.pop!
  end

  def check_time_attribute node, attribute
    relative_location "@#{attribute}"

    unless node.respond_to? attribute
      add_error :missing
      @location.pop!
      return
    end

    raw_duration = node[attribute]
    duration = raw_duration.to_f
    if duration == 0 && raw_duration != '0' && raw_duration != '0.0'
      add_error :not_numeric
    elsif duration < 0
      add_error :not_greater_than_or_equal_to
    else
      yield duration if block_given?
    end

    @location.pop!
  end

  def relative_location relative
    @location = @location.relative relative
  end

  def add_error reason, relative_location = nil
    @context.add_error reason: reason, location: relative_location ? @location.relative(relative_location) : @location
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
        location: @parser.location
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
