# frozen_string_literal: true

class User < ApplicationRecord
  # Gravatar
  include Gravtastic
  gravtastic

  # Roles only not authorization
  rolify
  ROLES = %i[admin finance kol bd spectator super_admin].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable, :registerable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: true

  # Relationships
  belongs_to :organization, optional: true

  def deactivate!
    update(deactivated_at: Time.zone.now)
  end

  def activate!
    update(deactivated_at: nil)
  end

  def active_for_authentication?
    super && deactivated_at.nil?
  end

  def add_role(role, org = nil)
    return false if organization.present? && role == :super_admin

    super(role, org)
  end

  # Flipper ID is the email address
  def flipper_id
    email
  end
  def self.ransackable_associations(auth_object = nil)
    ["organization", "roles"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "deactivated_at", "email", "encrypted_password", "id", "id_value", "name", "organization_id", "remember_created_at", "reset_password_sent_at", "reset_password_token", "updated_at"]
  end
end
