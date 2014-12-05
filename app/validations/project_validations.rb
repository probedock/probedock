class ProjectValidations
  include Errapi::Model

  errapi :model do
    validates :name, presence: true
  end
end
