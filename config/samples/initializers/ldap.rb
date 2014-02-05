Devise.setup do |config|

  if ROXCenter::AUTHENTICATION_MODULE == 'ldap'
    config.ldap_logger = true
    config.ldap_create_user = true
    config.ldap_update_password = false
    config.ldap_config = "#{Rails.root}/config/ldap.yml"
    config.ldap_check_group_membership = false
    config.ldap_check_attributes = false
    config.ldap_ad_group_check = false
    # set to false if you want to use anonymous binding
    config.ldap_use_admin_to_bind = true
  end
end
