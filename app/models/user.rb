class User < ApplicationRecord
  # Built-in Rails support for password hashing (requires 'bcrypt' gem)
  has_secure_password

  # Encrypt Todoist token in the database
  encrypts :todoist_access_token

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 },
            format: {
              with: /\A(?=.*[A-Z])(?=.*[^A-Za-z0-9]).+\z/,
              message: I18n.t("sessions.signup.password_invalid")
            },
            allow_nil: true

  # check if user is connected to todoist
  def todoist_linked?
    todoist_access_token.present?
  end
end
