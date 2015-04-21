module SecureRandom
  ALPHANUMERIC = [*'0'..'9', *'a'..'z'] unless defined?(ALPHANUMERIC)

  def self.random_alphanumeric length = 10
    Array.new(length){ ALPHANUMERIC[random_number(36)] }.join
  end
end
