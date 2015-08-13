Then /a registration e-mail for the last registration should be queued for sending/ do
  last_registration = UserRegistration.order('created_at DESC').first
  expect(last_registration).not_to be_blank, "No user registration was found in the database"
  expect_mailer_job UserMailer, :new_registration_email, last_registration
end
