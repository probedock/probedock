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

namespace :users do

  desc %|Give administrator privileges to a user|
  task :admin, [ :name ] => :environment do |t,args|

    user = User.where(name: args.name).first

    unless user
      puts Paint["No user found with name #{args.name}", :red]
      next
    end

    user.roles << :admin
    user.save!

    puts Paint["User #{user.name} is now an administrator", :green]
  end
end
