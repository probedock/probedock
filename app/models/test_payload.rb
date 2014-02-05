class TestPayload < ActiveRecord::Base
  belongs_to :user

  scope :waiting_for_processing, -> { where(state: :created).order('received_at ASC') }

  include SimpleStates
  states :created, :processing, :processed
  event :start_processing, from: :created, to: :processing
  event :finish_processing, from: :processing, to: :processed
end
