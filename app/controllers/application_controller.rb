class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Avoid csrf
  protect_from_forgery with: :exception

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Current user
  helper_method :current_user

  def current_user
    # Memoize to avoid dupe users
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    redirect_to login_path, alert: "Please sign in first." unless current_user
  end
end
