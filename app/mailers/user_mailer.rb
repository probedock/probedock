class UserMailer < ApplicationMailer
  include ERB::Util

  def new_membership_email membership

    @membership = membership

    @otp_url = [ root_url, 'new-member' ].collect{ |s| s.sub(/^\//, '').sub(/\/$/, '') }.join('/')
    @otp_url += '?otp=' + url_encode(membership.otp)

    mail to: membership.organization_email.address, subject: "Invitation to join #{membership.organization.effective_name}"
  end
end
