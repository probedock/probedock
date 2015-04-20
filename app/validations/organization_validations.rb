class OrganizationValidations < Errapi::SingleValidator
  configure do
    validates :name, presence: true, length: { maximum: 100 }
  end
end
