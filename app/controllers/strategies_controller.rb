class StrategiesController < ApplicationController
  before_action :logged_in_admin
  before_action :set_strategies, only: [:show, :edit]

  # GET /strategies
  def show
  end

  # GET /strategies/edit
  def edit
  end

  # PUT /strategies
  def update
    @errors = []
    if params[:strategy]
      params[:strategy].each do |k, v|
        s = Strategy.find_by_key k
        next unless s
        @errors << s.errors unless s.update value: v
      end
    else
      @errors << 'null parameters'
    end

    set_strategies
    if @errors.empty?
      render :show, notice: t('updating_success')
    else
      render :show, alert: t('updating_failed') + @errors.inspect
    end
  end

  private

  def set_strategies
    @strategies = current_admin.root? ? Strategy.all : Strategy.find_by_root('FALSE')
  end

end
