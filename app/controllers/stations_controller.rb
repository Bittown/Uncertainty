class StationsController < ApplicationController
  before_action :logged_in_admin, only: [:index, :new, :create]
  before_action :logged_in_station, except: [:index, :new, :create], unless: :current_admin
  before_action :set_station, only: [:show, :edit, :update, :refresh_pin]
  before_action :check_self, only: [:show, :edit, :update, :refresh_pin], if: :current_station

  # GET /stations
  def index
    if params[:mobile] && !params[:mobile].empty?
      @stations = Station.where(mobile: params[:mobile].strip).paginate(
          page: params[:page], per_page: 10)
    else
      @stations = Station.all.paginate page: params[:page], per_page: 10
    end
  end

  # GET /stations/:mobile
  def show
  end

  # GET /stations/new
  def new
    @station = Station.new
  end

  # GET /stations/:mobile/edit
  def edit
  end

  # POST /stations
  def create
    @station = Station.new(station_params)
    render :new, alert: t('invalid_pin') and return unless valid_admin_pin?
    @station.active = true

    if @station.save
      redirect_to @station, notice: t('creating_success')
    else
      render :new, alert: t('creating_failed')
    end
  end

  # PATCH/PUT /stations/:mobile
  def update
    render :edit, alert: t('invalid_pin') and return unless
        (current_admin && valid_admin_pin?) || (current_station && valid_station_pin?)

    if @station.update(station_params)
      redirect_to @station, notice: t('updating_success')
    else
      render :edit, alert: t('updating_failed')
    end
  end

  # PUT /admin/:mobile/refresh_pin.js
  def refresh_pin
    @station.gen_pin
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_station
    @station = Station.find params[:id]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def station_params
    params.require(:station).permit(:name, :mobile, :password, :password_confirmation)
  end

  def check_self
    redirect_back fallback_location: root_path, alert: t('no_privilege') unless
        current_station.id == @station.id
  end

  def valid_admin_pin?
    current_admin.valid_pin? params[:admin_pin].to_i
  end

  def valid_station_pin?
    current_station.valid_pin? params[:station_pin].to_i
  end

end
