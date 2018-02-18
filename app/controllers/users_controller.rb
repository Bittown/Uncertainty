class UsersController < ApplicationController
  before_action :logged_in_admin, except: [:refresh_pin]
  before_action :logged_in_station, only: [:refresh_pin], unless: :current_admin

  before_action :set_user, only: [:show, :refresh_pin]


  # GET /users
  def index
    if params[:mobile] && !params[:mobile].empty?
      @users = User.where(mobile: params[:mobile].strip).paginate(
          page: params[:page], per_page: 10)
    else
      @users = User.all.paginate page: params[:page], per_page: 10
    end
  end

  # GET /users/mobile
  def show
  end

  # PUT /user/:mobile/refresh_pin.js
  def refresh_pin
    unless @user
      @user = User.new(mobile: params[:mobile])
      unless @user.save
        logger.info {"failed to save user with mobile #{params[:mobile]}"}
        return
      end
    end

    @user.gen_pin
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_by_mobile params[:mobile]
  end

end
