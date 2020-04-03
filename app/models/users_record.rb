class UsersRecord < ApplicationRecord
    has_one_attached :dp
    has_one_attached :coverPhoto
    has_many :tweets
    has_many :followings
    has_many :followers
    has_secure_password
    validates :userfullname,:useremail,:username, presence: true, on: :create
    # ^@?(\w){1,15}$
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    #VALID_USER_NAME = \A^@?(\w){1,15}\z/i
    validates :useremail, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    validates_uniqueness_of :username, uniqueness: { case_sensitive: false }
    validates_confirmation_of :password,  on: :create
end