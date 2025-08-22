class Appointment < ApplicationRecord
  # 関連
  belongs_to :branch
  belongs_to :slot
  belongs_to :appointment_type
  
  # Enum定義
  enum :status, {
    booked: 0,          # 予約済み
    visited: 1,         # 来店済み
    needs_followup: 2,  # フォローアップ必要
    canceled: 3         # キャンセル
  }, default: :booked
  
  # バリデーション
  validates :name, presence: true
  validates :furigana, presence: true,
                      format: { 
                        with: /\A[ァ-ヶー・＝　]+\z/,
                        message: "は全角カタカナで入力してください"
                      }
  validates :phone, presence: true,
                   format: { 
                     with: /\A\d{10,11}\z/,
                     message: "は10〜11桁の数字で入力してください"
                   }
  validates :email, format: { 
                      with: URI::MailTo::EMAIL_REGEXP,
                      message: "の形式が正しくありません"
                    },
                    allow_blank: true
  validates :party_size, presence: true,
                        numericality: { 
                          greater_than: 0,
                          message: "は1以上の数値を入力してください"
                        }
  validates :accept_privacy, acceptance: { message: "に同意していただく必要があります" }
  
  # カスタムバリデーション
  validate :no_duplicate_appointment_on_same_day
  validate :slot_has_capacity
  
  # スコープ
  scope :active, -> { where.not(status: :canceled) }
  scope :today, -> { joins(:slot).where(slots: { starts_at: Date.current.beginning_of_day..Date.current.end_of_day }) }
  scope :future, -> { joins(:slot).where('slots.starts_at > ?', Time.current) }
  scope :past, -> { joins(:slot).where('slots.starts_at < ?', Time.current) }
  
  # コールバック
  after_create :increment_slot_booked_count
  after_update :update_slot_booked_count_on_status_change
  
  # インスタンスメソッド
  def appointment_date
    slot&.starts_at&.to_date
  end
  
  def appointment_time
    return nil unless slot
    "#{slot.starts_at.strftime('%H:%M')} - #{slot.ends_at.strftime('%H:%M')}"
  end
  
  def can_cancel?
    booked? && slot.starts_at > Time.current
  end
  
  def cancel!
    return false unless can_cancel?
    
    transaction do
      update!(status: :canceled)
      slot.decrement_booked_count!(party_size)
    end
    true
  end
  
  private
  
  def no_duplicate_appointment_on_same_day
    return unless phone.present? && slot
    
    # 同じ電話番号で同じ日に既存の予約があるかチェック
    existing = Appointment.active
                          .joins(:slot)
                          .where(phone: phone)
                          .where.not(id: id) # 更新時は自分自身を除外
                          .where(slots: { 
                            starts_at: slot.starts_at.beginning_of_day..slot.starts_at.end_of_day 
                          })
    
    if existing.exists?
      errors.add(:base, "同じ電話番号で同日の予約が既に存在します")
    end
  end
  
  def slot_has_capacity
    return unless slot && party_size
    
    # 新規作成時のみチェック（更新時はステータス変更で対応）
    if new_record? && slot.remaining_capacity < party_size
      errors.add(:base, "予約枠の残り定員が不足しています")
    end
  end
  
  def increment_slot_booked_count
    slot.increment_booked_count!(party_size)
  rescue => e
    errors.add(:base, e.message)
    throw :abort
  end
  
  def update_slot_booked_count_on_status_change
    return unless saved_change_to_status?
    
    previous_status = status_before_last_save
    
    # キャンセルに変更された場合
    if canceled? && previous_status != 'canceled'
      slot.decrement_booked_count!(party_size)
    # キャンセルから復活した場合
    elsif !canceled? && previous_status == 'canceled'
      slot.increment_booked_count!(party_size)
    end
  rescue => e
    errors.add(:base, e.message)
    throw :abort
  end
end