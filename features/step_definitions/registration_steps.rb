Given /user (.+) registered with e-mail (.+) and created (.+) organization (.+)/ do |user_name,user_email,org_access,org_display_name|

  user = create :new_user, name: user_name, primary_email: create(:email, address: user_email)
  org = create :new_organization, name: org_display_name.downcase.gsub(/\s+/, '-'), display_name: org_display_name, public_access: !!org_access.match(/^public$/i)
  registration = create :registration, user: user, organization: org

  add_named_record user.name, user
  add_named_record org.display_name, org
end
