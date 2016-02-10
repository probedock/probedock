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
    user = User.new name: name, primary_email: email, password: password, active: true
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

  desc %|Transform a human user into a technical user|
  task :technical, [ :name ] => :environment do |t,args|

    unless name = args[:name]
      puts Paint[%/A username must be given as first argument/, :red]
      next
    end

    unless user = User.where(name: name).first
      puts Paint[%/No user found with name #{name}/, :red]
      next
    end

    unless user.human?
      puts Paint[%/User #{name} is already a technical user/, :yellow]
      next
    end

    if user.memberships.blank?
      puts Paint[%/User #{name} belongs to no organization/, :red]
      next
    end

    if user.memberships.length >= 2
      puts Paint[%/User #{name} belongs to multiple organizations (technical users can only belong to one organization)/, :red]
      next
    end

    User.transaction do

      emails = user.emails.to_a

      # unlink and deactivate all e-mails
      emails.each do |email|
        email.user = nil
        email.active = false
        email.save!
      end

      # remove password and primary e-mail
      user.password = nil
      user.primary_email = nil

      # set technical flag
      user.technical = true
      user.technical_validation_disabled = true
      user.save!

      # remove acceptation date and organization e-mail from membership
      membership = user.memberships.first
      membership.accepted_at = nil
      membership.organization_email = nil
      membership.save!

      puts Paint[%/User #{name} is now a technical user (unlinked emails: #{emails.collect(&:address).sort.join(', ')})/, :green]
    end
  end

  desc %|Anonymize production data|
  task anonymize: [ :environment ] do
    n = User.where('password_digest IS NOT NULL').update_all password_digest: '$2a$10$dosjxExLYJe21YQT88Be4e9DCpnhHUN8nKCxszAV1hVJ59z9hIzc6'
    puts Paint[%/Password of #{n} users set to "test"/, :green]
  end
end
