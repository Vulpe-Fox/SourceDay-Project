module LoginHelpers
  def login(email = nil)
    user = email ? User.find_by(email: email) : User.first
    session[:user_id] = user&.id
    Rails.logger.info "Logged in as #{user&.email}"
  end
end
