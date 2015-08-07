class UserMailer < ApplicationMailer
  include ERB::Util

  def new_membership_email membership
    @membership = membership
    @otp_url = otp_url 'new-member', :otp, membership.otp
    mail to: membership.organization_email.address, subject: "Probe Dock: Invitation to join #{membership.organization.effective_name}"
  end

  def new_registration_email registration
    @registration = registration
    @otp_url = otp_url 'confirm-registration', :otp, registration.otp
    mail to: registration.user.primary_email.address, subject: "Probe Dock: Confirm your registration"
  end

  private

  def otp_url path, otp_param, otp
    join_url_parts(root_url, path) + '?' + otp_param.to_s + '=' + url_encode(otp.to_s)
  end

  def join_url_parts *parts
    parts.collect{ |s| s.to_s.sub(/^\//, '').sub(/\/$/, '') }.join('/')
  end
end
