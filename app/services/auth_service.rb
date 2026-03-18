class AuthService
  include HTTParty
  base_uri 'https://api.todoist.com/oauth'

  # keep development keys out of git
  AUTH_URL = "https://todoist.com/oauth/authorize"
  TOKEN_URL = "https://api.todoist.com/oauth/access_token"

  def initialize
    @client_id = ENV['TODOIST_CLIENT_ID']
    @client_secret = ENV['TODOIST_CLIENT_SECRET']
  end

  # generate auth url (step 1 in auth flow)
  def authorize_url(state, scopes = [])
    params = {
      client_id: @client_id,
      scope: scopes.join(','),
      state: state,
      response_type: 'code'
    }
    "#{AUTH_URL}?#{params.to_query}"
  end

  # exchange code for access token (step 3 in auth flow)
  def exchange_code(code)
    options = {
      body: {
        client_id: @client_id,
        client_secret: @client_secret,
        code: code
      }
    }

    response = self.class.post(TOKEN_URL, options)
    handle_response(response, "Token exchange failed")
  end

  # Revoke an existing OAuth access token
  def revoke_token(access_token)
    options = {
      body: {
        client_id: @client_id,
        client_secret: @client_secret,
        token: access_token,
        token_type_hint: 'access_token' # optional - RFC7009
      }
    }
    
    response = self.class.post('/access_token/revoke', options)
    response.success?
  end

  # Migrates an old email/password "personal token" to a new OAuth token
  def migrate_personal_token(personal_token, scopes = [])
    options = {
      body: {
        client_id: @client_id,
        client_secret: @client_secret,
        personal_token: personal_token,
        scope: scopes.join(',')
      }
    }

    response = self.class.post('/access_token/migrate', options)
    handle_response(response, "Migration failed")
  end

  private

  # DRY response handler
  def handle_response(response, default_error)
    if response.success?
      response.parsed_response
    else
      error_msg = ""
      if response.parsed_response.is_a?(Hash)
        error_msg = response.parsed_response.fetch("error", default_error)
      else
        # If it's a string (like "Bad Request") or nil, use it or the default
        error_msg = response.parsed_response.presence || default_error
      end
      raise StandardError, error_msg
    end
  end
end
