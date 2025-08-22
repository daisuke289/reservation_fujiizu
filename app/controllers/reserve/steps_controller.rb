class Reserve::StepsController < ApplicationController
  before_action :initialize_session
  before_action :set_area, only: [:branch]
  before_action :set_branch, only: [:datetime]
  before_action :set_slot, only: [:customer]
  
  def index
    redirect_to action: :area
  end
  
  # エリア選択
  def area
    @areas = Area.includes(:branches).order(:name)
  end
  
  # 支店選択
  def branch
    unless params[:area_id].present?
      redirect_to action: :area, alert: 'エリアを選択してください'
      return
    end
    
    @branches = @area.branches.order(:name)
    session[:reservation][:area_id] = @area.id
  end
  
  # 日時選択
  def datetime
    unless params[:branch_id].present?
      redirect_to action: :area, alert: '支店を選択してください'
      return
    end
    
    @available_slots = @branch.slots
                              .future
                              .available
                              .where(starts_at: Time.current.beginning_of_day..(2.weeks.from_now.end_of_day))
                              .includes(:branch)
                              .order(:starts_at)
    
    # 日付ごとにグループ化
    @slots_by_date = @available_slots.group_by { |slot| slot.starts_at.to_date }
    
    session[:reservation][:branch_id] = @branch.id
  end
  
  # 顧客情報入力
  def customer
    unless params[:slot_id].present?
      redirect_to action: :area, alert: '日時を選択してください'
      return
    end
    
    @appointment_types = AppointmentType.order(:name)
    @appointment = build_appointment_from_session
    
    session[:reservation][:slot_id] = @slot.id
  end
  
  # 次のステップへ進む処理
  def next
    case params[:current_step]
    when 'area'
      redirect_to action: :branch, area_id: params[:area_id]
    when 'branch'
      redirect_to action: :datetime, branch_id: params[:branch_id]
    when 'datetime'
      redirect_to action: :customer, slot_id: params[:slot_id]
    when 'customer'
      if save_customer_info
        redirect_to reserve_confirm_path
      else
        @appointment_types = AppointmentType.order(:name)
        @appointment = build_appointment_from_session
        render :customer
      end
    else
      redirect_to action: :area
    end
  end
  
  private
  
  def initialize_session
    session[:reservation] ||= {}
  end
  
  def set_area
    @area = Area.find(params[:area_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to action: :area, alert: '指定されたエリアが見つかりません'
  end
  
  def set_branch
    @branch = Branch.find(params[:branch_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to action: :area, alert: '指定された支店が見つかりません'
  end
  
  def set_slot
    @slot = Slot.find(params[:slot_id])
    
    # スロットが予約可能かチェック
    unless @slot.available?
      redirect_to action: :area, alert: '選択された時間は既に満員です。別の時間をお選びください'
      return
    end
    
    # スロットが未来の日時かチェック
    unless @slot.starts_at > Time.current
      redirect_to action: :area, alert: '過去の日時は選択できません'
      return
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to action: :area, alert: '指定された時間が見つかりません'
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
    @appointment = build_appointment_from_session
    @appointment.assign_attributes(customer_params)
    
    if @appointment.valid?
      session[:reservation][:customer_info] = customer_params.to_h
      true
    else
      false
    end
  end
  
  def customer_params
    params.require(:appointment).permit(
      :name, :furigana, :phone, :email, :party_size, 
      :purpose, :notes, :accept_privacy, :appointment_type_id
    )
  end
end