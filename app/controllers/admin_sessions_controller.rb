class AdminSessionsController < ApplicationController

  before_action :prevent_duplicated, except: [:destroy]


  def new
    redirect_to current_admin if current_admin
  end

  def create
    admin = Admin.find_by_mobile params[:session][:mobile]
    unless admin && admin.authenticate(params[:session][:password])
      flash.now[:alert] = t 'sessions.invalid_combination'
      render('new') and return
    end

    unless admin.active?
      redirect_to root_path, alert: "#{t 'sessions.disabled'}: #{admin.name}"
      return
    end

    login_admin admin
    logout_station
    redirect_to admin
  end

  def destroy
    logout_admin
    redirect_to admin_login_path
  end

  def prevent_duplicated
    redirect_to current_admin if current_admin
  end
end
