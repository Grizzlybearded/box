class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :name, :investor_id, :invitation_token
  belongs_to :investor, inverse_of: :users
  has_secure_password
  attr_readonly :investor_id, :invitation_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, 
  			uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: 6}
  validates :password_confirmation, presence: true
  validates :name, presence: true, length: {maximum: 50}
  validates :investor, presence: true
  validates :invitation_id, uniqueness: true, presence: true

  #added this later - may need to add it back in?
  #validates :invitation, presence: true, 

  has_many :sent_invitations, class_name: 'Invitation', foreign_key: 'sender_id'
  belongs_to :invitation

  before_save { |user| user.email = email.downcase }

  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end
end