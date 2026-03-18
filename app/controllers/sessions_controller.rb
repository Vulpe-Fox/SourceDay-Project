class SessionsController < ApplicationController
  def create_developer_session
    user = User.first
    if user
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in as #{user.email}"
    else
      redirect_to root_path, alert: t("sessions.developer_no_users")
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: t("sessions.logged_out_success")
  end
end
