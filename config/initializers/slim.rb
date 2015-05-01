slim_options = {
  # Disable {} attributes to play nice with angular
  attr_list_delims: { '(' => ')', '[' => ']' }
}

slim_options[:pretty] = Rails.env == 'development'

Slim::Engine.set_options slim_options
