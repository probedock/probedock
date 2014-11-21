# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
require 'paint'

namespace :docker do

  desc %|Build the development Docker image and push it to the registry|
  task :publish, [ :username, :repo, :tag ] do |t,args|

    unless username = args[:username]
      puts Paint['A Docker Hub username must be given as first argument', :red]
      next
    end

    unless repo = args[:repo]
      puts Paint['A Docker Hub repository name must be given as second argument', :red]
      next
    end

    unless tag = args[:tag]
      puts Paint['A tag to apply to the Docker image must be given as third argument', :red]
      next
    end

    dir = Rails.root.join 'docker', 'dev'
    image = "#{username}/#{repo}:#{tag}"

    puts
    puts Paint["Copying Gemfile and Gemfile.lock...", :bold]
    Dir.chdir Rails.root
    FileUtils.cp %w(Gemfile Gemfile.lock), dir
    puts Paint['Done', :green]

    Dir.chdir dir

    puts
    puts Paint["Building Docker image...", :bold]
    time = Benchmark.realtime{ system "docker build -t #{image} ." }
    puts Paint["Done in #{time.round 3}s", :green]

    puts
    puts Paint["Pushing Docker image...", :bold]
    time = Benchmark.realtime{ system "docker push #{image}" }
    puts Paint["Done in #{time.round 3}s", :green]

    puts
    puts Paint["All done!", :bold, :green]
    puts
  end
end
