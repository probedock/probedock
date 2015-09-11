#!/usr/bin/env ruby
require 'handlebars'

# Validate command-line arguments.
dest = ARGV.shift
raise "First argument should be the directory into which to generate the configuration files" unless dest
raise "#{dest} is not a directory" unless File.directory? dest

# Compiles a template file into the specified destination directory.
def generate_config handlebars, template_file, dest_file, template_options = {}
  template = handlebars.compile File.read(template_file)
  compiled = template.call template_options
  File.open(dest_file, 'w'){ |f| f.write compiled }
end

handlebars = Handlebars::Context.new
templates_dir = File.dirname __FILE__

# Collect relevant environment variables.
env_variables = ENV.select{ |k,v| k.match /^PROBEDOCK_/ }
env_variables.merge! 'RAILS_ENV' => ENV['RAILS_ENV']

# Prepare template options (strings must be marked as safe for handlebars to prevent HTML escaping).
template_options = env_variables.inject({}){ |memo,(k,v)| memo[k] = ->{ Handlebars::SafeString.new(v) }; memo }

# Generate the environment configuration file.
dest_file = File.join dest, '.env'
generate_config handlebars, File.join(templates_dir, 'env.handlebars'), dest_file, template_options
puts "Successfully generated #{dest_file}"

# Generate the docker compose configuration file.
dest_file = File.join dest, 'docker-compose.yml'
generate_config handlebars, File.join(templates_dir, 'docker-compose.handlebars'), dest_file, template_options
puts "Successfully generated #{dest_file}"
