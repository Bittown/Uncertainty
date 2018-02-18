module AdminSessionsHelper

  def login_admin(admin)
    session[:admin_mobile] = admin.mobile
    @current_admin = admin
  end

  def logout_admin
    session.delete :admin_mobile
    @current_admin = nil
  end

  def current_admin
    return @current_admin if @current_admin
    return @current_admin if session[:admin_mobile] &&
        (@current_admin = Admin.find_by_mobile(session[:admin_mobile]))
  end

end
