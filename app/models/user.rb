class User < ApplicationRecord

  include Sms

  self.primary_key = :mobile

  has_many :tickets,
           foreign_key: :user_mobile,
           inverse_of: :user

  validates :mobile,
            presence: true,
            format: {with: /\A\d{11}\z/},
            uniqueness: {case_sensative: true}

  def to_param
    mobile
  end

  def notify_ret(ret, wons)
    logger.debug {"Send ret #{ret} #{wons} to #{mobile}"}
    Sms.send_result mobile, ret, wons
  end

  def notify_ticket(ticket_id, bought_on)
    logger.debug {"Send ticket #{ticket_id} #{bought_on} to #{mobile}"}
    Sms.send_ticket mobile, ticket_id, bought_on
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
    save if send_sms_pin
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
