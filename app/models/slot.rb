class Slot < ApplicationRecord
  # 関連
  belongs_to :branch
  has_many :appointments, dependent: :destroy
  
  # バリデーション
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :capacity, presence: true,
                      numericality: { greater_than: 0 }
  validates :booked_count, presence: true,
                          numericality: { greater_than_or_equal_to: 0 }
  
  # カスタムバリデーション
  validate :ends_at_after_starts_at
  validate :booked_count_not_exceed_capacity
  
  # スコープ
  scope :available, -> { where('booked_count < capacity') }
  scope :future, -> { where('starts_at > ?', Time.current) }
  scope :on_date, ->(date) { where(starts_at: date.beginning_of_day..date.end_of_day) }
  
  # インスタンスメソッド
  def available?
    booked_count < capacity
  end
  
  def full?
    booked_count >= capacity
  end
  
  def remaining_capacity
    capacity - booked_count
  end
  
  # 予約時にbooked_countをインクリメント
  def increment_booked_count!(count = 1)
    with_lock do
      reload
      raise "予約枠が満員です" if booked_count + count > capacity
      increment!(:booked_count, count)
    end
  end
  
  # キャンセル時にbooked_countをデクリメント
  def decrement_booked_count!(count = 1)
    with_lock do
      reload
      raise "予約数が不正です" if booked_count - count < 0
      decrement!(:booked_count, count)
    end
  end
  
  private
  
  def ends_at_after_starts_at
    return unless starts_at.present? && ends_at.present?
    
    if ends_at <= starts_at
      errors.add(:ends_at, "は開始時刻より後に設定してください")
    end
  end
  
  def booked_count_not_exceed_capacity
    return unless booked_count.present? && capacity.present?
    
    if booked_count > capacity
      errors.add(:booked_count, "は定員を超えることはできません")
    end
  end
end