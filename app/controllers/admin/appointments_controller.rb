class Admin::AppointmentsController < Admin::BaseController
  before_action :set_appointment, only: [:show, :update]
  
  def index
    @appointments = Appointment.joins(:slot, :branch, :appointment_type)
                              .includes(:slot, :branch, :appointment_type)
    
    # フィルタ処理
    case params[:filter]
    when 'today'
      @appointments = @appointments.where(slots: { starts_at: current_date.beginning_of_day..current_date.end_of_day })
      @filter_title = "本日の予約"
    when 'tomorrow'
      @appointments = @appointments.where(slots: { starts_at: tomorrow_date.beginning_of_day..tomorrow_date.end_of_day })
      @filter_title = "翌日の予約"
    when 'booked'
      @appointments = @appointments.where(status: :booked)
      @filter_title = "予約済み"
    when 'visited'
      @appointments = @appointments.where(status: :visited)
      @filter_title = "来店済み"
    when 'needs_followup'
      @appointments = @appointments.where(status: :needs_followup)
      @filter_title = "要フォローアップ"
    when 'canceled'
      @appointments = @appointments.where(status: :canceled)
      @filter_title = "キャンセル"
    else
      @filter_title = "全ての予約"
    end
    
    # 支店フィルタ
    if params[:branch_id].present?
      @appointments = @appointments.where(branch_id: params[:branch_id])
    end
    
    # 日付範囲フィルタ
    if params[:date_from].present?
      @appointments = @appointments.where('slots.starts_at >= ?', Date.parse(params[:date_from]).beginning_of_day)
    end
    
    if params[:date_to].present?
      @appointments = @appointments.where('slots.starts_at <= ?', Date.parse(params[:date_to]).end_of_day)
    end
    
    # 検索（名前・電話番号）
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @appointments = @appointments.where(
        'appointments.name ILIKE ? OR appointments.phone ILIKE ?',
        search_term, search_term
      )
    end
    
    @appointments = @appointments.order('slots.starts_at DESC')
                                .page(params[:page])
                                .per(20)
    
    # フィルタ用のデータ
    @branches = Branch.order(:name)
    @current_filter = params[:filter]
    @current_branch = params[:branch_id]
    @current_search = params[:search]
    @current_date_from = params[:date_from]
    @current_date_to = params[:date_to]
  end
  
  def show
    @reception_number = format('%08d', @appointment.id)
  end
  
  def update
    case params[:action_type]
    when 'status'
      update_status
    when 'memo'
      update_memo
    else
      redirect_to admin_appointment_path(@appointment), alert: '無効な操作です。'
    end
  end
  
  private
  
  def set_appointment
    @appointment = Appointment.find(params[:id])
  end
  
  def update_status
    new_status = params[:appointment][:status]
    
    if @appointment.update(status: new_status)
      case new_status
      when 'visited'
        flash[:notice] = '来店済みに更新しました。'
      when 'needs_followup'
        flash[:notice] = '要フォローアップに更新しました。'
      when 'canceled'
        flash[:notice] = 'キャンセルに更新しました。'
      end
    else
      flash[:alert] = '更新に失敗しました。'
    end
    
    redirect_to admin_appointment_path(@appointment)
  end
  
  def update_memo
    if @appointment.update(admin_memo: params[:appointment][:admin_memo])
      flash[:notice] = 'メモを更新しました。'
    else
      flash[:alert] = 'メモの更新に失敗しました。'
    end
    
    redirect_to admin_appointment_path(@appointment)
  end
  
  def appointment_params
    params.require(:appointment).permit(:status, :admin_memo)
  end
end