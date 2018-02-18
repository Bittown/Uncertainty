class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include StationSessionsHelper
  include AdminSessionsHelper
  include ApplicationHelper

  def logged_in_station
    return if current_station
    redirect_to login_path
  end

  def logged_in_admin
    return if current_admin
    redirect_to admin_login_path
  end

end
