class AppointmentService
  include ActiveModel::Model
  include ActiveModel::Attributes
  
  class ReservationError < StandardError; end
  class SlotUnavailableError < ReservationError; end
  class DuplicateReservationError < ReservationError; end
  
  def self.create_appointment(appointment_params)
    new.create_appointment(appointment_params)
  end
  
  def create_appointment(appointment_params)
    appointment = nil
    
    ActiveRecord::Base.transaction do
      # 1. スロットの残枠確認
      slot = Slot.lock.find(appointment_params[:slot_id])
      
      unless slot.available?
        raise SlotUnavailableError, "選択された時間枠は満員です。別の時間をお選びください。"
      end
      
      # 2. 同一電話番号・同一日の重複予約チェック
      if duplicate_reservation_exists?(appointment_params[:phone], slot)
        raise DuplicateReservationError, "同一の電話番号で同日の予約が既に存在します。"
      end
      
      # 3. Appointment作成
      appointment = Appointment.new(appointment_params)
      
      unless appointment.valid?
        raise ReservationError, appointment.errors.full_messages.join(", ")
      end
      
      # 4. スロットの予約数をインクリメント（楽観的ロック）
      party_size = (appointment_params[:party_size] || 1).to_i

      # 再度残枠確認（他のリクエストとの競合対策）
      slot.reload
      if slot.booked_count + party_size > slot.capacity
        raise SlotUnavailableError, "予約枠の残り定員が不足しています。別の時間をお選びください。"
      end
      
      # Appointmentを保存（コールバックでslot.booked_countが更新される）
      appointment.save!
      
      # 5. 確認メール送信（非同期）
      if appointment.email.present?
        AppointmentMailJob.perform_later(appointment.id)
      end
    end
    
    appointment
  rescue ActiveRecord::RecordInvalid => e
    raise ReservationError, e.record.errors.full_messages.join(", ")
  rescue SlotUnavailableError, DuplicateReservationError
    raise
  rescue StandardError => e
    Rails.logger.error "予約作成エラー: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise ReservationError, "予約の作成中にエラーが発生しました。しばらく時間をおいてから再度お試しください。"
  end
  
  private
  
  def duplicate_reservation_exists?(phone, slot)
    return false unless phone.present? && slot.present?
    
    # 同じ電話番号で同じ日に既存の予約があるかチェック
    Appointment.active
               .joins(:slot)
               .where(phone: phone)
               .where(slots: { 
                 starts_at: slot.starts_at.beginning_of_day..slot.starts_at.end_of_day 
               })
               .exists?
  end
end