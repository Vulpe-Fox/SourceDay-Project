class User < ApplicationRecord
  # Built-in Rails support for password hashing (requires 'bcrypt' gem)
  has_secure_password

  # Encrypt Todoist token in the database
  encrypts :todoist_access_token

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  # check if user is connected to todoist
  def todoist_linked?
    todoist_access_token.present?
  end
end
