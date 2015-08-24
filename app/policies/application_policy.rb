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
class ApplicationPolicy
  include PolicyHelpers

  attr_reader :record

  def initialize user, record
    @user = user
    @record = record
    expand_user_context!
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope! user, record.class
  end

  def serializer
    serializer_class = self.class::Serializer
    raise NotDefinedError, "unable to find serializer `#{self.class}::Serializer`" unless serializer_class
    serializer_class.new @user_context || @user, @record
  end

  public

  class Scope
    include PolicyHelpers

    attr_reader :scope

    def initialize user, scope
      @user = user
      @scope = scope
      expand_user_context!
    end

    def resolve
      scope
    end
  end

  class Serializer
    include PolicyHelpers

    attr_reader :record

    def initialize user, record
      @user = user
      @record = record
      expand_user_context!
    end

    def serialize *args
      options = args.extract_options!
      if other_record = args.shift
        if other_record.kind_of? Array
          other_record.collect do |r|
            Pundit.policy!(@user_context || @user, r).serializer.serialize options
          end
        else
          Pundit.policy!(@user_context || @user, other_record).serializer.serialize options
        end
      else
        to_builder(options).attributes!
      end
    end

    def to_builder options = {}
      Jbuilder.new do |json|
        build json, options
      end
    end

    def build json, options = {}
      # To be implemented by subclasses.
    end
  end
end
