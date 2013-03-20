class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :name, :investor_id, :invitation_token
  belongs_to :investor
  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, 
  			uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: 6}
  validates :password_confirmation, presence: true
  validates :name, presence: true, length: {maximum: 50}
  validates :investor_id, presence: true
  validates :invitation_id, uniqueness: true, presence: true

  has_many :sent_invitations, class_name: 'Invitation', foreign_key: 'sender_id'
  belongs_to :invitation

  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end
end