class EaseljController < ApplicationController
  before_action :logged_in_station, unless: :current_admin

  layout false, except: [:race, :alien, :free_alien]

  def tutorial
  end

  def platformer1
  end

  def platformer2
  end

  def run
  end

  def race
    @game = ::Game.first
  end

  def alien
  end

  def free_alien
  end

end
