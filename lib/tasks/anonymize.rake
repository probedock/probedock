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

if Rails.env != 'production'

  desc "Anonymize a production dump"
  task :anonymize => [ :environment, 'cache:clear' ] do

    User.all.to_a.each do |user|
      user.api_keys.to_a.each{ |k| k.tap{ |k| k.send :set_shared_secret }.tap(&:save!) }
      user.encrypted_password = '$2a$12$QPPUK39lqu68/rOZEL2N0Obwee2gI1uEffdnogGncY8tyGL3Umrcy'
      user.save!
    end

    puts Paint[%/All passwords set to "test"./, :green]
    puts Paint[%/All api keys randomized./, :green]
    puts Paint[%/All caches cleared. Run `rake cache:warmup` if necessary./, :yellow]
  end
end
