#!/usr/bin/env ruby
require 'handlebars'
require 'fileutils'
require 'pathname'

templates_dir = '/probedock-templates'
dest_dir = '/probedock-configs'

# Validate command-line arguments.
template_file = ARGV.shift
dest_file = ARGV.shift
raise "If passing arguments, the source (first argument) and destination (second argument) files must be given" if template_file && !dest_file

template_files = if template_file
  [ template_file ]
else
  pattern = File.join templates_dir, '**', '*.handlebars'
  Dir.glob(pattern).collect{ |f| Pathname.new(f).relative_path_from(Pathname.new(templates_dir)).to_s }
end

template_dests = if dest_file
  [ dest_file ]
else
  template_files.collect{ |f| File.join dest_dir, f.sub(/\.handlebars$/, '') }
end

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

%w(RAILS_ENV).each do |var|
  env_variables[var] = ENV[var] if ENV.key? var
end

# Prepare template options (strings must be marked as safe for handlebars to prevent HTML escaping).
template_options = env_variables.inject({}){ |memo,(k,v)| memo[k] = ->{ Handlebars::SafeString.new(v) }; memo }

# Generate each configuration file.
FileUtils.mkdir_p dest_dir
template_files.each.with_index do |file,i|
  generate_config handlebars, file, template_dests[i], template_options
  puts "Successfully generated #{template_dests[i]}"
end
