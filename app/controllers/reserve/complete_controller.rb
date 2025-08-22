class Reserve::CompleteController < ApplicationController
  before_action :set_appointment
  
  def index
    # 完了画面を表示
    @reception_number = format('%08d', @appointment.id)
  end
  
  private
  
  def set_appointment
    @appointment = Appointment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: '予約情報が見つかりません。'
  end
end