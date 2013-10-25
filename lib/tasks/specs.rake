# Copyright (c) 2012-2013 Lotaris SA
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

if Rails.env != 'production'
  require 'fileutils'
  require 'rspec/core/rake_task'

  namespace :spec do

    namespace :jasmine do

      task :run do
        system "grunt"
      end

      desc "Compile assets for jasmine code examples"
      task :assets do

        src = File.join Rails.root, 'public' ,'assets'
        dest = File.join Rails.root, 'tmp', 'jasmine'

        begin

          FileUtils.remove_entry_secure dest if File.exists? dest
          FileUtils.mkdir_p dest

          ENV['RAILS_ENV'] = 'development'
          Rake::Task['assets:precompile'].invoke

          FileUtils.cp_r src, dest

        ensure
          FileUtils.remove_entry_secure src
        end
      end

      desc "Run the jasmine code examples in spec/javascripts without re-compiling assets"
      task :fast => [ 'spec:jasmine:run' ]
      task :full => [ 'spec:jasmine:assets', 'spec:jasmine:run' ]
    end

    desc "Run the jasmine code examples in spec/javascripts"
    task :jasmine => [ 'spec:jasmine:full' ]
  end
end
