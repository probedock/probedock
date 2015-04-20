class ProjectValidations < Errapi::SingleValidator
  configure do
    validates :name, presence: true, length: { maximum: 100 }
    validates :description, length: { maximum: 1000 }
  end
end
