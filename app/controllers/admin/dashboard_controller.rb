class Admin::DashboardController < Admin::BaseController
  def index
    # 本日の予約数
    @today_appointments_count = Appointment.joins(:slot)
                                          .where(slots: { starts_at: current_date.beginning_of_day..current_date.end_of_day })
                                          .active
                                          .count
    
    # 翌日の予約数
    @tomorrow_appointments_count = Appointment.joins(:slot)
                                             .where(slots: { starts_at: tomorrow_date.beginning_of_day..tomorrow_date.end_of_day })
                                             .active
                                             .count
    
    # 未確認予約数（予約済みステータス）
    @pending_appointments_count = Appointment.booked.count
    
    # 今日の予約一覧（簡易表示用）
    @today_appointments = Appointment.joins(:slot, :branch, :appointment_type)
                                    .includes(:slot, :branch, :appointment_type)
                                    .where(slots: { starts_at: current_date.beginning_of_day..current_date.end_of_day })
                                    .active
                                    .order('slots.starts_at ASC')
                                    .limit(10)
    
    # 翌日の予約一覧（簡易表示用）
    @tomorrow_appointments = Appointment.joins(:slot, :branch, :appointment_type)
                                       .includes(:slot, :branch, :appointment_type)
                                       .where(slots: { starts_at: tomorrow_date.beginning_of_day..tomorrow_date.end_of_day })
                                       .active
                                       .order('slots.starts_at ASC')
                                       .limit(10)
    
    # 最近の予約一覧
    @recent_appointments = Appointment.joins(:slot, :branch, :appointment_type)
                                     .includes(:slot, :branch, :appointment_type)
                                     .order(created_at: :desc)
                                     .limit(5)
  end
end