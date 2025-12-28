class Reserve::ConfirmController < ApplicationController
  before_action :normalize_session
  before_action :check_reservation_session
  before_action :load_reservation_data
  
  def index
    # 確認画面を表示
  end
  
  def create
    begin
      @appointment = AppointmentService.create_appointment(appointment_params)
      
      # セッションをクリア
      session[:reservation] = {}
      redirect_to reserve_complete_path(id: @appointment.id), notice: 'ご予約が完了しました。'
      
    rescue AppointmentService::ReservationError => e
      # サービスクラスからのエラーを表示
      flash.now[:alert] = e.message
      render :index
      
    rescue StandardError => e
      # 予期しないエラー
      Rails.logger.error "予約確定エラー: #{e.message}"
      flash.now[:alert] = '予約の確定中にエラーが発生しました。しばらく時間をおいてから再度お試しください。'
      render :index
    end
  end
  
  private

  def normalize_session
    return unless session[:reservation].present?
    session[:reservation] = session[:reservation].to_h.with_indifferent_access
  end

  def check_reservation_session
    reservation = session[:reservation]
    unless reservation.present? &&
           (reservation[:branch_id] || reservation['branch_id']).present? &&
           (reservation[:slot_id] || reservation['slot_id']).present? &&
           (reservation[:customer_info] || reservation['customer_info']).present?
      redirect_to reserve_steps_path, alert: '予約情報が不完全です。最初からやり直してください。'
    end
  end
  
  def load_reservation_data
    reservation = session[:reservation]
    @branch = Branch.find(reservation[:branch_id] || reservation['branch_id'])
    @slot = Slot.find(reservation[:slot_id] || reservation['slot_id'])
    customer_info = reservation[:customer_info] || reservation['customer_info']
    @customer_info = customer_info.is_a?(Hash) ? customer_info.with_indifferent_access : customer_info
    @appointment_type = AppointmentType.find(@customer_info[:appointment_type_id])
    
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