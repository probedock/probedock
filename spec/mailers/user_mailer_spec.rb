require 'spec_helper'

RSpec.describe UserMailer, type: :mailer, probedock: { tags: %w(unit mailer) } do
  let(:app_config){ Rails.application.config_for(:application).with_indifferent_access }

  describe "#new_registration_email" do
    let(:user){ create :new_user }
    let(:organization){ create :new_organization }
    let(:registration){ create :registration, user: user, organization: organization }
    subject!{ UserMailer.new_registration_email(registration).deliver_now }

    before :each do
      expect_delivery
    end

    it "should have the correct :from address", probedock: { key: 'b9jm' } do
      expect(subject.from).to eq([ app_config[:mail_from] ])
    end

    it "should have the correct :to address", probedock: { key: 'nsu6' } do
      expect(subject.to).to eq([ user.primary_email.address ])
    end

    it "should have the correct subject", probedock: { key: 'hvxk' } do
      expect(subject.subject).to eq('Probe Dock: Confirm your registration')
    end

    it "should contain the username of the registered user", probedock: { key: 'e6tx' } do
      expect(subject.body.encoded).to match(/You have just registered as .*?#{user.name}/)
    end

    it "should contain a link to confirm the registration", probedock: { key: 'q74v' } do
      expected_url = %|#{root_url.to_s.sub(/\/$/, '')}/confirm-registration?otp=#{Rack::Utils.escape(registration.otp)}|
      expect(subject.body.encoded).to include(expected_url)
    end
  end

  def expect_delivery
    expect(ActionMailer::Base.deliveries).to have(1).item
  end
end
