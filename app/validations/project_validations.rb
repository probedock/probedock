class ProjectValidations < Errapi::SingleValidator
  configure do
    validates :name, presence: true, length: { maximum: 100 }
    validates :description, length: { maximum: 1000 }
    validates :repo_url, length: { maximum: 100 }
  end
end
