# adapted to rspec 3 from https://github.com/ryanb/cancan/blob/1.6.10/lib/cancan/matchers.rb
RSpec::Matchers.define :be_able_to do |*args|

  match do |ability|
    ability.can?(*args)
  end

  failure_message do |ability|
    "expected to be able to #{args.map(&:inspect).join(" ")}"
  end

  failure_message_when_negated do |ability|
    "expected not to be able to #{args.map(&:inspect).join(" ")}"
  end
end
