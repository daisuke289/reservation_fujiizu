class Admin::PrintsController < Admin::BaseController
  def index
    # 当日の予約を印刷用に取得
    @target_date = params[:date].present? ? Date.parse(params[:date]) : current_date

    @appointments = Appointment.joins(:slot, :branch, :appointment_type)
                              .includes(:slot, :branch, :appointment_type)
                              .where(slots: { starts_at: @target_date.beginning_of_day..@target_date.end_of_day })
                              .active
                              .order('branches.name ASC, slots.starts_at ASC')
    
    # 支店別にグループ化
    @appointments_by_branch = @appointments.group_by(&:branch)
    
    # 印刷レイアウトを使用
    render layout: 'print'
  end
end