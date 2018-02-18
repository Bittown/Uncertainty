class Strategy < ApplicationRecord

  self.primary_key = :key

  validates :key, presence: true, uniqueness: {case_sensitive: true}
  validates :describe, presence: true, allow_blank: false

  def to_param
    key
  end

end
