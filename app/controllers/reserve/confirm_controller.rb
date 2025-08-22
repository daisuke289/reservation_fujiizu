class Reserve::ConfirmController < ApplicationController
  before_action :check_reservation_session
  before_action :load_reservation_data
  
  def index
    # 確認画面を表示
  end
  
  def create
    @appointment = Appointment.new(appointment_params)
    
    if @appointment.save
      # セッションをクリア
      session[:reservation] = {}
      redirect_to reserve_complete_path(id: @appointment.id)
    else
      # エラーがある場合は確認画面に戻る
      render :index
    end
  end
  
  private
  
  def check_reservation_session
    unless session[:reservation].present? && 
           session[:reservation][:branch_id].present? && 
           session[:reservation][:slot_id].present? && 
           session[:reservation][:customer_info].present?
      redirect_to reserve_steps_path, alert: '予約情報が不完全です。最初からやり直してください。'
    end
  end
  
  def load_reservation_data
    @branch = Branch.find(session[:reservation][:branch_id])
    @slot = Slot.find(session[:reservation][:slot_id])
    @appointment_type = AppointmentType.find(session[:reservation][:customer_info][:appointment_type_id])
    @customer_info = session[:reservation][:customer_info]
    
    # 再度スロットの可用性をチェック
    unless @slot.available?
      redirect_to reserve_steps_path, alert: '選択された時間は既に満員です。別の時間をお選びください。'
      return
    end
    
    # 予約オブジェクトを構築（表示用）
    @appointment = Appointment.new(
      branch: @branch,
      slot: @slot,
      appointment_type: @appointment_type,
      name: @customer_info[:name],
      furigana: @customer_info[:furigana],
      phone: @customer_info[:phone],
      email: @customer_info[:email],
      party_size: @customer_info[:party_size] || 1,
      purpose: @customer_info[:purpose],
      notes: @customer_info[:notes],
      accept_privacy: @customer_info[:accept_privacy] == '1'
    )
  rescue ActiveRecord::RecordNotFound
    redirect_to reserve_steps_path, alert: '予約情報が無効です。最初からやり直してください。'
  end
  
  def appointment_params
    {
      branch_id: @branch.id,
      slot_id: @slot.id,
      appointment_type_id: @appointment_type.id,
      name: @customer_info[:name],
      furigana: @customer_info[:furigana],
      phone: @customer_info[:phone],
      email: @customer_info[:email],
      party_size: @customer_info[:party_size] || 1,
      purpose: @customer_info[:purpose],
      notes: @customer_info[:notes],
      accept_privacy: @customer_info[:accept_privacy] == '1'
    }
  end
end