class Admin < ApplicationRecord

  include Sms

  DISABLED = 0
  NORMAL = 1
  ROOT = 2

  def self.levels
    [DISABLED, NORMAL, ROOT]
  end

  def self.to_level_title(level)
    case level
      when DISABLED
        'Disabled'
      when NORMAL
        'Normal'
      when ROOT
        'Root'
      else
        'Unknown'
    end
  end


  has_secure_password

  has_many :games,
           foreign_key: :created_by,
           inverse_of: :creator

  validates :name,
            presence: true,
            length: {maximum: 128}

  validates :mobile,
            presence: true,
            format: {with: /\A\d{11}\z/},
            uniqueness: {case_sensative: true}

  validates :password, presence: true, length: {minimum: 8}, allow_nil: true

  validates :level,
            inclusion: {in: levels}

  default_scope -> {order(level: :desc)}


  def active?
    level == NORMAL || level == ROOT
  end

  def root?
    level == ROOT
  end

  def level_title
    Admin.to_level_title level
  end

  def notify_game_freeze(minutes, ret)
    logger.debug {"Send game freezing notify #{minutes} minutes to #{mobile}"}
    Sms.send_game_freeze mobile, minutes, ret
  end

  def gen_pin
    now = Time.zone.now
    if pin_due
      if now > pin_due - 3.minutes
        create_pin
      else
        logger.debug {"Already sent pin for #{mobile}, due #{pin_due}"}
      end
    else
      create_pin
    end
  end

  def create_pin
    self.pin = rand 1_000..9_999
    self.pin_due = Time.zone.now + 4.minutes
    send_sms_pin if save
  end

  def valid_pin?(new_pin)
    if pin_due && pin_due > Time.zone.now && pin == new_pin
      update pin_due: nil
      return true
    end
    false
  end

  def send_sms_pin
    logger.debug { "Send pin #{pin} to #{mobile}" }
    Sms.send_pin mobile, pin
  end

end

