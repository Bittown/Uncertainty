class StationSessionsController < ApplicationController

  before_action :prevent_duplicated, except: [:destroy]

  # GET login
  def new
    redirect_to current_station if current_station
  end

  # POST login
  def create
    station = Station.find_by_mobile params[:session][:mobile]
    unless station && station.authenticate(params[:session][:password])
      flash.now[:alert] = t 'sessions.invalid_combination'
      render 'new' and return
    end

    unless station.active?
      redirect_to root_path, alert: "#{t 'sessions.disabled'}: #{station.name}"
      return
    end

    login_station station
    logout_admin
    redirect_to station
  end

  # DELETE logout
  def destroy
    logout_station
    redirect_to login_path
  end


  def prevent_duplicated
    redirect_to current_station if current_station
  end

end
