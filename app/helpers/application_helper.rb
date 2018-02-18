module ApplicationHelper

  def current_game
    Game.unexposed.first
  end

end
