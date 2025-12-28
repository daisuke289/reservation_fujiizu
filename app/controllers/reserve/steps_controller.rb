class Reserve::StepsController < ApplicationController
  before_action :initialize_session
  before_action :set_area, only: [:branch]
  before_action :set_branch, only: [:calendar, :time_selection]
  before_action :set_slot, only: [:customer]
  
  def index
    redirect_to reserve_steps_area_path
  end
  
  # エリア選択
  def area
    @areas = Area.includes(:branches).active_ordered
  end
  
  # 支店選択
  def branch
    unless params[:area_id].present?
      redirect_to reserve_steps_area_path, alert: 'エリアを選択してください'
      return
    end
    
    @branches = @area.branches.order(:name)
    session[:reservation][:area_id] = @area.id
  end
  
  # カレンダー表示
  def calendar
    unless params[:branch_id].present?
      redirect_to reserve_steps_area_path, alert: '支店を選択してください'
      return
    end

    # パラメータから年月を取得（デフォルト: 今月）
    # ?ym=2026-1 形式をサポート
    if params[:ym].present?
      year, month = params[:ym].split('-').map(&:to_i)
      @year = year
      @month = month
    else
      @year = (params[:year] || Date.today.year).to_i
      @month = (params[:month] || Date.today.month).to_i
    end

    @target_date = Date.new(@year, @month, 1)

    # 表示可能期間のチェック（今月・来月のみ）
    current_month = Date.today.beginning_of_month
    next_month = current_month.next_month

    unless [@target_date, current_month, next_month].include?(@target_date)
      @year = current_month.year
      @month = current_month.month
      @target_date = current_month
    end

    # 前月・次月の計算
    @prev_month = @target_date.prev_month
    @next_month = @target_date.next_month

    # 予約可能日の計算
    @available_dates = calculate_available_dates(@branch, @year, @month)

    # 祝日情報の計算
    @holidays = calculate_holidays(@year, @month)

    session[:reservation][:branch_id] = @branch.id
  end

  # 時間選択
  def time_selection
    unless params[:date].present?
      redirect_to reserve_steps_calendar_path(branch_id: params[:branch_id]), alert: '日付を選択してください'
      return
    end

    @selected_date = Date.parse(params[:date])

    # 過去日チェック
    if @selected_date < Date.today
      redirect_to reserve_steps_calendar_path(branch_id: params[:branch_id]), alert: '過去の日付は選択できません'
      return
    end

    # その日の利用可能なスロットを取得
    @available_slots = @branch.slots
      .future
      .available
      .where(starts_at: @selected_date.beginning_of_day..@selected_date.end_of_day)
      .order(:starts_at)

    if @available_slots.empty?
      redirect_to reserve_steps_calendar_path(branch_id: params[:branch_id]), alert: 'この日は予約できません'
      return
    end

    session[:reservation][:selected_date] = @selected_date.to_s
  end
  
  # 顧客情報入力
  def customer
    unless params[:slot_id].present?
      redirect_to reserve_steps_area_path, alert: '日時を選択してください'
      return
    end

    @appointment_types = AppointmentType.order(:name)
    @appointment = build_appointment_from_session

    session[:reservation][:slot_id] = @slot.id
    Rails.logger.info "🔵 CUSTOMER action - Set session[:reservation][:slot_id] = #{@slot.id}"
    Rails.logger.info "🔵 CUSTOMER action - Full session: #{session[:reservation].inspect}"
  end
  
  # 次のステップへ進む処理
  def next
    case params[:current_step]
    when 'area'
      redirect_to reserve_steps_branch_path(area_id: params[:area_id])
    when 'branch'
      redirect_to reserve_steps_calendar_path(branch_id: params[:branch_id])
    when 'calendar'
      redirect_to reserve_steps_time_selection_path(
        branch_id: params[:branch_id],
        date: params[:selected_date]
      )
    when 'time_selection'
      redirect_to reserve_steps_customer_path(slot_id: params[:slot_id])
    when 'customer'
      Rails.logger.info "🟡 NEXT action (customer) - Session: #{session[:reservation].inspect}"

      if save_customer_info
        redirect_to reserve_confirm_path
      else
        slot_id = session[:reservation][:slot_id]
        Rails.logger.info "🔴 NEXT action - Validation failed, slot_id from session: #{slot_id.inspect}"

        unless slot_id
          Rails.logger.error "❌ NEXT action - slot_id is nil! Redirecting to area page"
          redirect_to reserve_steps_area_path, alert: 'セッションが切れました。最初からやり直してください。'
          return
        end

        @appointment_types = AppointmentType.order(:name)
        # Don't rebuild @appointment - save_customer_info already set it with user input and validation errors
        @slot = Slot.find(slot_id)
        Rails.logger.info "✅ NEXT action - Re-rendering customer form with errors"
        render :customer
      end
    else
      redirect_to reserve_steps_area_path
    end
  end
  
  private
  
  def initialize_session
    session[:reservation] ||= {}
  end
  
  def set_area
    @area = Area.find(params[:area_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to reserve_steps_area_path, alert: '指定されたエリアが見つかりません'
  end
  
  def set_branch
    @branch = Branch.find(params[:branch_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to reserve_steps_area_path, alert: '指定された支店が見つかりません'
  end
  
  def set_slot
    @slot = Slot.find(params[:slot_id])
    
    # スロットが予約可能かチェック
    unless @slot.available?
      redirect_to reserve_steps_area_path, alert: '選択された時間は既に満員です。別の時間をお選びください'
      return
    end
    
    # スロットが未来の日時かチェック
    unless @slot.starts_at > Time.current
      redirect_to reserve_steps_area_path, alert: '過去の日時は選択できません'
      return
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to reserve_steps_area_path, alert: '指定された時間が見つかりません'
  end
  
  def build_appointment_from_session
    customer_info = session[:reservation][:customer_info] || {}
    
    Appointment.new(
      name: customer_info[:name],
      furigana: customer_info[:furigana],
      phone: customer_info[:phone],
      email: customer_info[:email],
      party_size: customer_info[:party_size] || 1,
      purpose: customer_info[:purpose],
      notes: customer_info[:notes],
      accept_privacy: customer_info[:accept_privacy] == '1'
    )
  end
  
  def save_customer_info
    # セッションの値を先に取得（assign_attributesの影響を避けるため）
    Rails.logger.info "🟢 Session before extraction: #{session[:reservation].inspect}"
    Rails.logger.info "🟢 Session keys: #{session[:reservation].keys.inspect}"
    slot_id_from_session = session[:reservation][:slot_id] || session[:reservation]['slot_id']
    branch_id_from_session = session[:reservation][:branch_id] || session[:reservation]['branch_id']
    Rails.logger.info "🟢 Extracted - slot_id: #{slot_id_from_session.inspect}, branch_id: #{branch_id_from_session.inspect}"

    @appointment = build_appointment_from_session
    @appointment.assign_attributes(customer_params)

    # セッションから取得した値を設定（バリデーションに必要）
    @appointment.slot_id = slot_id_from_session
    @appointment.branch_id = branch_id_from_session
    Rails.logger.info "🟢 After setting - @appointment.slot_id: #{@appointment.slot_id.inspect}, branch_id: #{@appointment.branch_id.inspect}"

    if @appointment.valid?
      session[:reservation][:customer_info] = customer_params.to_h
      true
    else
      Rails.logger.error "❌ Validation errors: #{@appointment.errors.full_messages.join(', ')}"
      false
    end
  end
  
  def customer_params
    params.require(:appointment).permit(
      :name, :furigana, :phone, :email, :party_size,
      :purpose, :notes, :accept_privacy, :appointment_type_id
    )
  end

  def calculate_available_dates(branch, year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    available_dates = {}

    (start_date..end_date).each do |date|
      # 過去日は×
      if date < Date.today
        available_dates[date] = false
        next
      end

      # 営業日判定
      unless SlotGeneratorService.business_day?(date)
        available_dates[date] = false
        next
      end

      # その日に利用可能なスロットがあるか
      has_available_slots = branch.slots
        .future
        .available
        .where(starts_at: date.beginning_of_day..date.end_of_day)
        .exists?

      available_dates[date] = has_available_slots
    end

    available_dates
  end

  def calculate_holidays(year, month)
    require 'holiday_jp'
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    holidays = {}
    (start_date..end_date).each do |date|
      holiday = HolidayJp.holiday?(date)
      if holiday
        holidays[date] = HolidayJp.between(date, date).first.name
      end
    end

    holidays
  end
end