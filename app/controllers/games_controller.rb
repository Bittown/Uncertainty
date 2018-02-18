class GamesController < ApplicationController
  before_action :logged_in_admin, except: [:index, :show, :status, :current_status, :expose, :expose_current]
  before_action :logged_in_station, only: [:index, :show, :status, :current_status, :expose, :expose_current], unless: :current_admin

  before_action :set_game, only: [:show, :expose, :status, :hurry]
  before_action :no_more_new_game, only: [:create, :new]


  # GET /games
  def index
    if expose_time
      if params[:unexposed_only]
        @games = Game.where('exposed_at is null and should_expose_at > ?',
                            expose_time).paginate(
            page: params[:page], per_page: 10)
        return
      end

      @games = Game.where('should_expose_at > ?', expose_time).paginate(
          page: params[:page], per_page: 10)
      return
    end

    if params[:unexposed_only]
      @games = Game.where('exposed_at is null').paginate(
          page: params[:page], per_page: 10)
      return
    end

    @games = Game.all.paginate page: params[:page], per_page: 10
  end

  # GET /games/:id
  # GET /games/:id.json
  def show
    respond_to do |format|
      format.html do
        station_id = current_station.id if current_station
        station_id ||= params[:station_id]

        if station_id
          station_tickets = @game.tickets.select {|t| t.station_id == station_id}
          station_mobile = station_tickets[0] && station_tickets[0].station ?
                               station_tickets[0].station.mobile : nil
          @stations = station_mobile ? {station_mobile => station_tickets} : {}
        else
          @stations = {}
          @game.tickets.each do |ticket|
            @stations[ticket.station.mobile] = [] unless @stations[ticket.station.mobile]
            @stations[ticket.station.mobile] << ticket
          end
        end
      end

      format.json do
        render json: @game, status: 200
      end
    end
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # POST /games
  def create
    @game = Game.new created_by: current_admin.id,
                     should_expose_at: expose_time,
                     bg_style: params[:bg_style],
                     ground_style: params[:ground_style]
    render :new, alert: t('creating_failed') and return unless expose_time

    render(:new, alert: t('expose_time_should_be_latter')) and return if @game.can_expose?

    @game.result = ::Game::RET_UNKNOWN
    if @game.save
      redirect_to @game, notice: t('creating_success')
    else
      render :new, alert: t('creating_failed')
    end
  end

  # GET /games/current.js
  def current
    render json: {current: current_game ? current_game.id : -1}, status: :ok
  end

  # PUT /games/:id/expose.js
  def expose
    render(json: '', status: 204) and return unless @game
    render(json: {ret: @game.result}, status: :ok) and return if @game.exposed?
    if @game.expose_to_best
      render json: {ret: @game.result}, status: :ok
      notify_users @game
    else
      render json: {msg: 'Failed to expose'}, status: :unprocessable_entity
    end
  end

  # PUT /games/expose_current.js
  def expose_current
    game = current_game
    render(json: '', status: 204) and return unless game
    if game.expose_to_best
      render json: {ret: game.result}, status: :ok
      notify_users game
    else
      render json: {msg: 'Failed to expose'}, status: 201
    end
  end

  # GET /games/:id/status.js
  def status
    render(json: '', status: 204) and return unless @game
    render(json: {msg: 'exposed'}, status: 201) and return if @game.exposed?
    render(json: {tts: @game.should_expose_at + 1.minutes,
                  pref: @game.best_result,
                  bg: @game.bg_style,
                  ground: @game.ground_style,
                  first: @game.first_character_color,
                  second: @game.second_character_color}, status: 208) and return if @game.can_expose?
    render json: {tts: @game.should_expose_at,
                  pref: @game.best_result,
                  bg: @game.bg_style,
                  ground: @game.ground_style,
                  first: @game.first_character_color,
                  second: @game.second_character_color}, status: :ok
  end

  # GET /games/current_status.js
  def current_status
    game = current_game
    render(json: '', status: 204) and return unless game
    render(json: {tts: game.should_expose_at,
                  pref: game.best_result,
                  bg: game.bg_style,
                  ground: game.ground_style,
                  first: game.first_character_color,
                  second: game.second_character_color}, status: 208) and return if current_game.can_expose?
    render json: {tts: game.should_expose_at,
                  pref: game.best_result,
                  bg: game.bg_style,
                  ground: game.ground_style,
                  first: game.first_character_color,
                  second: game.second_character_color}, status: :ok
  end

  # PUT /games/:id/hurry.html
  def hurry
    redirect_to @game, alert: t('updating_failed') + ': is going to be exposed or already' and return unless
        (Time.zone.now + 4.minutes) < @game.should_expose_at
    if @game.update should_expose_at: Time.zone.now
      redirect_to @game, notice: t('updating_success')
    else
      logger.info{ @game.errors.inspect }
      redirect_to @game, alert: t('updating_failed')
    end
  end

  # GET /games/hurry.html
  def hurry_current
    game = current_game
    redirect_to game, alert: t('updating_failed') + ': is going to be exposed or already' and return unless
        (Time.zone.now + 4.minutes) < game.should_expose_at
    if game.update should_expose_at: Time.zone.now
      redirect_to game, notice: t('updating_success')
    else
      logger.info{ game.errors.inspect }
      redirect_to game, alert: t('updating_failed')
    end
  end

  private

  def notify_users(game)
    won_users = {}
    game.tickets.each do |t|
      next unless t.forecast == game.result
      if won_users[t.user.id]
        won_users[t.user.id] += " #{t.id}"
      else
        won_users[t.user.id] = t.id.to_s
      end
    end
    won_users.each do |k, v|
      User.find(k).notify_ret t(game.ret_color), v
    end
  end

  def valid_admin_pin?
    current_admin.valid_pin? params[:admin_pin].to_i
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expose_time
    return @expose_time if @expose_time

    expose_date = params[:game] ? params[:game][:expose_date] : params[:expose_date]
    expose_hour = params[:game] ? params[:game][:expose_hour] : params[:expose_hour]
    return nil unless expose_hour

    if expose_date && !expose_date.empty?
      expose_hour = expose_hour[/^(\d{1,2}:\d{1,2})$/, 1] if expose_hour && !expose_hour.empty?
      expose_hour = '0:0' unless expose_hour && !expose_hour.empty?
      @expose_time = Time.strptime(expose_date + '-' + expose_hour, '%m/%d/%Y-%H:%M')
    else
      @expose_time = nil
    end
  end

  def no_more_new_game
    redirect_back fallback_location: root_path,
                  alert: "#{t 'no_more_than_one_unexposed_at_a_time'}, #{t 'current' }#{t 'game'} #{current_game.id}" if current_game
  end

end
