module ErrapiUtils
  def add_location error, location, location_type
    error.location = location.to_s
    error.location.define_singleton_method(:serialize){ to_s }
    error.location.define_singleton_method(:location_type){ location_type.to_s }
  end

  extend self
end
