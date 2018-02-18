module GamesHelper

  def total_count(games)
    total = {paid: 0, sold_small: 0, sold_middle: 0, sold_big: 0, should_pay: 0}
    @games.each do |l|
      total[:paid] += l.paid
      total[:sold_small] += l.sold_small
      total[:sold_middle] += l.sold_middle
      total[:sold_big] += l.sold_big
      total[:should_pay] += l.should_pay
    end
    total
  end

  def count_sold_tickets(tickets)
    ret = {small: 0, middle: 0, big: 0}
    tickets.each do |t|
      case t.forecast
        when ::Game::RET_SMALL
          ret[:small] += t.amount
        when ::Game::RET_MIDDLE
          ret[:middle] += t.amount
        else
          ret[:big] += t.amount
      end
    end
    ret
  end

  def game_ret_as_str(game)
    logger.info{game.inspect}
    case(game.result)
      when Game::RET_SMALL
        return game.first_character_color
      when Game::RET_MIDDLE
        return 'equal'
      when Game::RET_BIG
        return game.second_character_color
      else
        return 'unknown'
    end
  end

end
