class OrganizationMember < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  # Valid roles
  ROLES = %w[owner admin member].freeze

  # Validations
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :organization_id, message: "is already a member of this organization" }

  # Scopes
  scope :owners, -> { where(role: 'owner') }
  scope :admins, -> { where(role: 'admin') }
  scope :members, -> { where(role: 'member') }

  # Role checks
  def owner?
    role == 'owner'
  end

  def admin?
    role == 'admin'
  end

  def member?
    role == 'member'
  end

  def can_manage_members?
    owner? || admin?
  end

  def can_manage_billing?
    owner?
  end
end
