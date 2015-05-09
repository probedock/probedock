# Copyright (c) 2015 42 inside
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of Probe Dock.
#
# Probe Dock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Probe Dock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.
namespace :templates do

  desc 'Compile all templates in app/views/templates to public/templates'
  task precompile: :environment do
    templates_dir = Rails.root.join 'app', 'views', 'templates'

    Dir.chdir templates_dir
    templates = Dir.glob('**/*.slim').reject{ |t| t.match /^(?:\.|_)/ }

    target_dir = Rails.root.join 'public', 'templates'
    FileUtils.mkdir_p target_dir

    templates.each do |template|
      source = File.join templates_dir, template
      target = File.join target_dir, template.sub(/\.slim$/, '')

      scope = Object.new
      options = {}
      rendered = Slim::Template.new(source, options).render(scope)

      File.open(target, 'w'){ |f| f.write rendered }

      puts Paint["#{Pathname.new(source).relative_path_from Rails.root} -> #{Pathname.new(target).relative_path_from Rails.root}", :green]
    end
  end
end
