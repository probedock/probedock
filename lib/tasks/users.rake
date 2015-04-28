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
require 'highline/import'

namespace :users do

  desc %|Give administrator privileges to a user|
  task :admin, [ :name ] => :environment do |t,args|

    unless user = User.where(name: args.name).first
      puts Paint["No user found with name #{args.name}", :red]
      next
    end

    user.roles << :admin
    user.save!

    puts Paint["User #{user.name} is now an administrator", :green]
  end

  desc %|Register a new user|
  task :register, [ :name, :email, :password ] => :environment do |t,args|

    unless name = args[:name]
      puts Paint[%/A username must be given as first argument/, :red]
      next
    end

    unless email_address = args[:email]
      puts Paint[%/An e-mail must be given as second argument/, :red]
      next
    end

    if user = User.where(name: name).first
      puts Paint["There is already a user with name #{name}", :red]
      next
    end

    if user = User.joins(:emails).where(emails: { address: email_address }).first
      puts Paint["There is already a user with e-mail #{email_address}", :red]
      next
    end

    password = args[:password] || ask('Enter the password of the new user: '){ |q| q.echo = false }
    if password.blank?
      puts Paint["Password cannot be blank", :red]
      next
    end

    email = Email.where(address: email_address).first_or_create active: true
    user = User.new name: name, primary_email: email, password: password
    user.primary_email.user = user

    user.save!

    puts Paint["User #{name} with e-mail #{email_address} was successfully created", :green]
  end

  desc %|Retrieve a user's ID|
  task :id, [ :name ] => :environment do |t,args|

    unless name = args[:name]
      puts Paint[%/A username must be given as first argument/, :red]
      next
    end

    unless user = User.where(name: name).first
      puts Paint[%/No user found with name #{name}/, :red]
      next
    end

    puts user.api_id
  end

  desc %|Generate an authentication token for a user|
  task :token, [ :name ] => :environment do |t,args|

    unless name = args[:name]
      puts Paint[%/A username must be given as first argument/, :red]
      next
    end

    unless user = User.where(name: name).first
      puts Paint[%/No user found with name #{name}/, :red]
      next
    end

    puts user.generate_auth_token
  end
end
