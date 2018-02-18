class TicketsController < ApplicationController
  before_action :logged_in_station, except: [:index, :show]
  before_action :logged_in_station, only: [:index, :show], unless: :current_admin

  before_action :set_ticket, only: [:show, :pay]
  before_action :check_ownership, only: [:show, :pay]


  # GET /tickets
  def index
    filter = {}
    filter[:station_id] = current_station.id if current_station
    filter[:paid] = false if params[:should_pay_only]

    should_search = true
    if params[:quest] && !params[:quest].empty?
      params[:quest].scan /((\w+)?\s+(\d+))/ do |x, y, z|
        filter[:user_mobile] = z and next unless y && !y.empty?
        case y
          when /user/
            filter[:user_mobile] = z
          when /station/
            if current_station
              flash.now[:info] = 'Station mobile has been ignored'
            else
              station = Station.find_by_mobile(z)
              unless station
                should_search = false
                @tickets = Ticket.none
                break
              end
              filter[:station_id] = station.id
            end
          when /game/
            filter[:game_id] = z
        end
        break unless should_search
      end
    end

    if should_search
      if params[:should_pay_only]
        @tickets = Ticket.where(filter).select(&:should_pay?)
      else
        @tickets = Ticket.where(filter).paginate(page: params[:page], per_page: 10)
      end
    end
  end

  # GET /tickets/:id
  def show
  end

  # GET /tickets/new
  def new
    @ticket = Ticket.new
  end

  # POST /tickets
  def create
    @ticket = Ticket.new ticket_params
    render(:new, alert: 'Failed on new ticket') and return unless
        @ticket && @ticket.user && @ticket.station && @ticket.game

    render(:new, alert: 'Game is freeze now') and return if
        @ticket.game.exposed? || @ticket.game.can_expose?

    render(:new, alert: t('invalid_pin')) and return unless verify_pin?

    if @ticket.save_all
      redirect_to(@ticket, notice: t('creating_success'))
      notify_user_bought
      return
    end

    render :new, alert: t('creating_failed')
  end

  # PUT /tickets/:id/pay
  def pay
    render(:show, alert: 'Invalid ticket') and return unless
        @ticket && @ticket.game && @ticket.user && @ticket.station

    render(:show, alert: 'Already paid') and return if
        @ticket.paid?

    render(:show, alert: 'Game is not exposed yet.') and return unless
        @ticket.game.exposed?

    render(:show, alert: t('invalid_pin')) and return unless verify_pin?

    render(:show, alert: 'Forecast is not correct') and return unless
        @ticket.forecast == @ticket.game.result

    redirect_to(@ticket, notice: t('paying_success')) and return if @ticket.pay

    render :show, alert: t('paying_failed')
  end


  private

  def verify_pin?
    @ticket.user && @ticket.user.valid_pin?(params[:user_pin].to_i)
  end

  def notify_user_bought
    @ticket.user.notify_ticket @ticket.id,
                               "#{@ticket.game.id}.#{@ticket.forecast}.#{@ticket.amount}"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ticket_params
    @ticket_params ||= params.require(:ticket).permit(
        :game_id, :station_id, :user_mobile, :amount, :forecast)
  end

  def check_ownership
    redirect_back fallback_location: root_path, alert: t('no_privilege') unless
        current_admin || current_station.id == @ticket.station_id
  end

end
