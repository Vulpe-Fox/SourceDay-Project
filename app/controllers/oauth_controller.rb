class OauthController < ApplicationController
  before_action :set_service

  # step 1 in auth flow
  def connect
    # Generate state
    #   SecureRandom adds a second layer to protect_from_forgery for CSRF
    state = SecureRandom.hex(24)
    session[:oauth_state] = state

    # Desired scopes (as a test, in practice use least privelege)
    scopes = [ "data:read", "task:add" ]

    redirect_to @service.authorize_url(state, scopes), allow_other_host: true
  end

  # Step 2,3: in auth flow using callback
  def callback
    # Match state for verification
    if params[:state].blank? || params[:state] != session[:oauth_state]
      return redirect_to root_path, alert: "Security Error: State mismatch."
    end

    # Remove old session state after verification to avoid 
    #   code injection retrieval and replay attacks
    session.delete(:oauth_state)

    # Check for returned errors to initial inquiry
    if params[:error]
      return handle_oauth_error(params[:error])
    end

    # Exchange code for token
    begin
      result = @service.exchange_code(params[:code])
      
      # Save to user model
      if current_user.update!(todoist_access_token: result["access_token"])
        redirect_to dashboard_path, notice: "Successfully connected to Todoist."
      else
        redirect_to root_path, alert: "Failed to save Todoist connection."
      end
    rescue => e
      redirect_to root_path, alert: "Authentication failed: #{e.message}"
    end
  end

  private
  
  def set_service
    @service = AuthService.new
  end

  def handle_oauth_error(error_type)
    message = case error_type
    when "access_denied" then "The request has been rejected."
    when "invalid_scope" then "The requested permissions are invalid."
    else "An unknown error occurred: #{error_type}"
    end
    redirect_to root_path, alert: message
  end
end
