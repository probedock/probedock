slim_options = {
  # Disable {} attributes to play nice with angular
  attr_delims: { '(' => ')', '[' => ']' }
}

slim_options[:pretty] = true if Rails.env == 'development'

Slim::Engine.set_default_options slim_options
