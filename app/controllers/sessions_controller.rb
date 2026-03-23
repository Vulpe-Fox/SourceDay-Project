class SessionsController < ApplicationController
  def create_developer_session
    user = User.find_or_create_by!(email: "dev@example.com") do |u|
      u.password = "Password123"
      u.password_confirmation = "Password123"
    end

    if user
      session[:user_id] = user.id
      @current_user = user
      redirect_to root_path, notice: "Logged in as #{user.email} (Dev Mode)"
    else
      redirect_to root_path, alert: t("sessions.developer_no_users")
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: t("sessions.logged_out_success")
  end
end
