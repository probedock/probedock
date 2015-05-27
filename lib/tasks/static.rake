# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
namespace :static do

  desc 'Copy all static assets in static to public'
  task :copy do

    target = Rails.root.join 'public'

    Dir.chdir Rails.root.join('static')

    Dir.glob('**/*').reject{ |f| f.match /^\./ }.each do |file|
      source = Rails.root.join 'static', file
      FileUtils.cp_r source, target
      puts Paint["#{Pathname.new(source).relative_path_from Rails.root} -> #{File.join 'public', file}", :green]
    end
  end
end
