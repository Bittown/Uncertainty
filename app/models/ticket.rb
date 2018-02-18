class Ticket < ApplicationRecord

  def self.unpaid
    find_by(paid: false)
  end

  belongs_to :game,
             inverse_of: :tickets

  belongs_to :station,
             foreign_key: :station_id,
             inverse_of: :tickets

  belongs_to :user,
             foreign_key: :user_mobile,
             inverse_of: :tickets


  validates :game_id, presence: true
  validates :station_id, presence: true
  validates :user_mobile, presence: true
  validates :amount, inclusion: {in: 1..9999}, presence: true
  validates :forecast, inclusion: {in: Game.valid_results}, presence: true

  default_scope -> {order(game_id: :desc)}


  def should_pay?
    !paid && won?
  end

  def won?
    game.exposed? && forecast == game.result
  end

  def save_all
    if game.exposed?
      errors[:base] << 'Exposed game is not for selling.'
      return false
    end

    case forecast
      when ::Game::RET_SMALL
        user_par = {bought_small: user.bought_small + amount}
        station_par = {sold_small: station.sold_small + amount}
        game_par = {sold_small: game.sold_small + amount}
      when ::Game::RET_MIDDLE
        user_par = {bought_middle: user.bought_middle + amount}
        station_par = {sold_middle: station.sold_middle + amount}
        game_par = {sold_middle: game.sold_middle + amount}
      when ::Game::RET_BIG
        user_par = {bought_big: user.bought_big + amount}
        station_par = {sold_big: station.sold_big + amount}
        game_par = {sold_big: game.sold_big + amount}
      else
        errors[:forecast] << "Invalid forecast #{forecast}"
        return false
    end

    save &&
        user.update(user_par) &&
        station.update(station_par) &&
        game.update(game_par)
  end

  def pay
    unless game.exposed?
      errors[:base] << 'UnExposed game is not for paying.'
      return false
    end

    update(paid: true) &&
        user.update(gained: user.gained + amount) &&
        update(paid: station.paid + amount) &&
        game.update(paid: game.paid + amount)
  end

end
