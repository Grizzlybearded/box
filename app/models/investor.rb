class Investor < ActiveRecord::Base
  attr_accessible :name, :invitation_token, :users_attributes
  has_many :users, inverse_of: :investor, dependent: :destroy
  accepts_nested_attributes_for :users
  attr_readonly :invitation_token

  belongs_to :invitation

  validates :name, presence: true
  has_many :relationships, dependent: :destroy
  has_many :funds, through: :relationships

  validates :invitation_id, uniqueness: true, presence: true

  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end
end