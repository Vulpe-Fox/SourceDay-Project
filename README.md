# SourceDay-Project

A Rails application which integrates with Todoist API v1 to create and view tasks within the Development Tasks project.

## Dependencies

httparty: Handles REST API requests to Todoist

devise: Manages user authentication for token retrieval

dotenv-rails: Manages client ids and secrets

rspec: Unit testing

## Services

The AuthService handles the OAuth token exchange for secure authentication

The TaskService handles the creation and retrieval of Todoist tasks

## Notable Security Considerations

Multilayer protections against CSRF attacks

Protections to avoid Injection Retrieval or Replay attacks inline

## Setup instructions

1. Install dependencies
```bash
bundle install
```

2. Create and migrate the database
```bash
bin/rails db:prepare
```

3. Prepare the test database (not necessary yet)
```bash
bin/rails db:test:prepare
```

4. Setup Todoist Configuration and Projects

&nbsp;&nbsp;4a. Create a Todoist account

&nbsp;&nbsp;4b. Navigate to Settings > Integrations > Developer > App management and create a new application

&nbsp;&nbsp;4c. Transfer client id, secret, and verification token to a .env file as:
TODOIST_CLIENT_ID={client id}
TODOIST_CLIENT_SECRET={client secret}
TODOIST_VERIFICATION_TOKEN={verification token}

&nbsp;&nbsp;4d. Set TODOIST_REDIRECT_URI in .env to http://localhost:3000/auth/todoist/callback, and copy that link into Todoist application OAuth redirect URL

&nbsp;&nbsp;4e. DEV_EMAIL, DEV_PASSWORD, and DEFAULT_PROJECT_NAME will be provided for ENV

&nbsp;&nbsp;4f. Create a new Todoist project named Development Tasks

5. Run the rails server in one terminal
```bash
bin/dev
```

6. Run the rails console in another terminal
```bash
rails c
```

7. In the development environment, control click the opened port to open the dev webpage, click the login at the top right to sign in to the created development account

8. In the top left or center of the screen, click the option to link Todoist

9. Follow through the OAuth authorization flow

10. You may now add tasks via the My Tasks view

11. Should you need to reauthenticate or change scopes, the home menu has an option to reconnect Todoist; Browse-dependent, restarting the dev server may cause an incorrect state as cookies are saved weirdly sometimes.


