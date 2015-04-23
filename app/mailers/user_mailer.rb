class UserMailer < ApplicationMailer
  def new_membership_email membership
    @membership = membership
    mail to: membership.organization_email.address, subject: "Invitation to join #{membership.organization.effective_name}"
  end
end
