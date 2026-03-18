module AuthenticationHelpers
  def sign_in(user)
    # Simulates a login by setting the session variable
    test_session = ActionController::TestSession.new(user_id: user.id)
    allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(test_session)
    
    # And mock the helper method
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end
  
  # Or mock the controller's current_user
  def login_as(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end
end