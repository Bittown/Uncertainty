module StationSessionsHelper

  def login_station(station)
    session[:station_id] = station.id
    @current_station = station
  end

  def logout_station
    session.delete :station_id
    @current_station = nil
  end

  def current_station
    return @current_station if @current_station

    return @current_station if session[:station_id] &&
        (@current_station = Station.find session[:station_id])
    nil
  end

end
