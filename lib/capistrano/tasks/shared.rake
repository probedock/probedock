# Copyright (c) 2015 ProbeDock
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
namespace :shared do

  task :setup do
    on roles(:app) do
      within shared_path do
        execute :mkdir, '-p', 'public/assets', 'tmp/cache'
      end
    end
  end

  task :setup_release do
    on roles(:app) do
      within release_path do
        execute :mkdir, '-p', 'public/assets', 'tmp/cache'
      end
    end
  end

  task :copy_assets do
    on roles(:app) do
      within release_path do
        execute :rsync, '--progress', "#{shared_path}/public/assets/", "#{release_path}/public/assets/"
        execute :rsync, "#{shared_path}/tmp/cache/", "#{release_path}/tmp/cache/"
      end
    end
  end

  task :update_assets do
    on roles(:app) do
      within release_path do
        execute :rsync, '--progress', "#{release_path}/public/assets/", "#{shared_path}/public/assets/"
        execute :rsync, "#{release_path}/tmp/cache/", "#{shared_path}/tmp/cache/"
      end
    end
  end
end
