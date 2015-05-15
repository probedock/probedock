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
class ApplicationPolicy
  attr_reader :user, :organization, :otp_record, :params, :record

  def initialize user, record
    @user = user
    @record = record

    if user.kind_of? UserContext
      @user_context = user
      @user = user.user
      @organization = user.organization
      @otp_record = user.otp_record
      @params = user.params
    end
  end

  def default?
    false
  end

  def collection_default?
    false
  end

  def index?
    collection_default?
  end

  def show?
    default?
  end

  def create?
    collection_default?
  end

  def update?
    default?
  end

  def destroy?
    default?
  end

  def scope
    Pundit.policy_scope! user, record.class
  end

  def serializer
    serializer_class = self.class::Serializer
    raise NotDefinedError, "unable to find serializer `#{self.class}::Serializer`" unless serializer_class
    serializer_class.new @user_context || @user, @record
  end

  class Scope
    attr_reader :user, :organization, :otp_record, :params, :scope

    def initialize user, scope
      @user = user
      @scope = scope

      if user.kind_of? UserContext
        @user = user.user
        @organization = user.organization
        @otp_record = user.otp_record
        @params = user.params
      end
    end

    def resolve
      scope
    end
  end

  class Serializer
    attr_reader :user, :record, :organization, :otp_record, :params

    def initialize user, record
      @user = user
      @record = record

      if user.kind_of? UserContext
        @user_context = user
        @user = user.user
        @organization = user.organization
        @otp_record = user.otp_record
        @params = user.params
      end
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
      Jbuilder.new{}
    end
  end
end
