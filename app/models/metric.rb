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
require 'active_support/concern'

module Metric
  extend ActiveSupport::Concern
  KEY_CHARACTERS = (48..57).to_a + (97..122).to_a

  included do
    before_create :set_metric_key
  end

  def set_metric_key
    self.metric_key = self.class.new_metric_key
  end

  module ClassMethods
    
    def new_metric_key
      next while exists?(metric_key: key = generate_metric_key)
      key
    end

    def generate_metric_key
      ([ nil ] * 5).map{ KEY_CHARACTERS.sample.chr }.join
    end
  end
end
