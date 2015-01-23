class ProjectValidations < Errapi::SingleValidator
  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 1000 }
end
