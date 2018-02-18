class Game < ApplicationRecord

  RET_UNKNOWN = 0
  RET_SMALL = 1
  RET_MIDDLE = 2
  RET_BIG = 3

  DEFAULT_FIRST_CHARACTER_COLOR = 'blue'
  DEFAULT_SECOND_CHARACTER_COLOR = 'pink'

  def self.valid_results
    [RET_SMALL, RET_MIDDLE, RET_BIG]
  end

  def self.results
    [RET_UNKNOWN, RET_SMALL, RET_MIDDLE, RET_BIG]
  end

  def self.ret_str(ret)
    case ret
      when RET_SMALL
        return 'activerecord.attributes.game.ret_small'
      when RET_MIDDLE
        return 'activerecord.attributes.game.ret_middle'
      when RET_BIG
        return 'activerecord.attributes.game.ret_big'
      else
        return 'activerecord.attributes.game.ret_unknown'
    end
  end

  def self.character_colors
    %w[beige blue green pink yellow]
  end

  def self.bg_styles
    %w[blue_desert blue_grass blue_land blue_shroom]
  end

  def self.ground_styles
    %w[dirt snow grass planet sand stone]
  end

  def self.unexposed
    where 'exposed_at is null'
  end

  def self.unexposed_ids
    Game.unexposed.map &:id
  end

  def self.exposed
    where 'exposed_at is not null'
  end

  def self.exposed_ids
    Game.exposed.map &:id
  end

  has_many :tickets,
           inverse_of: :game

  belongs_to :creator,
             class_name: 'Admin',
             foreign_key: :created_by,
             inverse_of: :games


  validates :should_expose_at,
            presence: true,
            allow_nil: false

  validates :created_by, presence: true

  # 0 as default, for unexposed game
  validates :result,
            inclusion: {in: Game.results},
            allow_nil: true

  validates :bg_style,
            inclusion: {in: Game.bg_styles},
            allow_nil: false

  validates :ground_style,
            inclusion: {in: Game.ground_styles},
            allow_nil: false

  validates :first_character_color,
            inclusion: {in: Game.character_colors},
            allow_nil: true

  validates :second_character_color,
            inclusion: {in: Game.character_colors},
            allow_nil: true

  validate :expose_time_should_match_result

  default_scope -> {order(should_expose_at: :desc)}


  def can_expose?
    Time.zone.now >= should_expose_at
  end

  def best_result
    sold_big > sold_small ? RET_SMALL : RET_BIG
  end

  def exposed?
    !!exposed_at
  end

  def frozen?
    !exposed? && can_expose?
  end

  def ret_color
    case result
      when RET_SMALL
        return first_character_color
      when RET_MIDDLE
        return 'middle'
      when RET_BIG
        return second_character_color
      else
        return 'unknown'
    end
  end

  def tickets_won
    return nil unless exposed?
    @tickets_won || (@tickets_won = tickets.select {|t| t.forecast == result})
  end

  def expose_to_best
    expose best_result
  end

  def expose(given_result)
    given_result = given_result.to_i
    errors[:result] << 'Already exposed' and return false if exposed?
    errors[:should_expose_at] << 'Too earlly to expose' and
        return false unless can_expose?

    case given_result
      when RET_SMALL
        should_pay = sold_small
      when RET_MIDDLE
        should_pay = sold_middle
      when RET_BIG
        should_pay = sold_big
      else
        errors[:result] << 'Invalid given result'
        return false
    end

    unless update result: given_result,
                  should_pay: should_pay,
                  exposed_at: Time.zone.now
      errors[:result] << 'Failed to update result'
      return false
    end

    if tickets_won
      sorted_tickets = tickets_won.sort_by &:station_id
      last_station = nil
      sorted_tickets.each do |ticket|
        if last_station && last_station.id != ticket.station_id
          last_station.update should_pay: last_station.should_pay
          last_station = nil
        end

        last_station = ticket.station unless last_station
        last_station.should_pay += ticket.amount
      end
      last_station.update should_pay: last_station.should_pay if last_station
    end
    true
  end


  private

  def expose_time_should_match_result
    errors.add(:result, 'Resut should be UNKNOWN for unexposed game') if exposed_at && result == RET_UNKNOWN
  end

end
