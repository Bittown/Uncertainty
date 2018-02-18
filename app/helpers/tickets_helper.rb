module TicketsHelper

  def result_as_str(result)
    case(result)
      when Game::RET_SMALL
        return Game::DEFAULT_FIRST_CHARACTER_COLOR
      when Game::RET_MIDDLE
        return 'equal'
      when Game::RET_BIG
        return Game::DEFAULT_SECOND_CHARACTER_COLOR
      else
        return 'unknown'
    end
  end

end
