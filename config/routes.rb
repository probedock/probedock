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
require 'resque/server'

ProbeDock::Application.routes.draw do

  if Rails.env == 'development'
    mount Resque::Server.new, at: '/resque'
  end

  if Rails.env != 'production'
    get '/templates/:name', to: 'home#template'
  end

  mount ProbeDock::API => '/api'

  get '/*path', to: 'home#index'
  root to: 'home#index'
end
