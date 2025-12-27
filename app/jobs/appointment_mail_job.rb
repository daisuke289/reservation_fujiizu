class AppointmentMailJob < ApplicationJob
  queue_as :default
  
  retry_on StandardError, wait: :polynomially_longer, attempts: 3
  
  def perform(appointment_id)
    appointment = Appointment.find_by(id: appointment_id)
    
    unless appointment
      Rails.logger.warn "AppointmentMailJob: Appointment ID #{appointment_id} not found"
      return
    end
    
    unless appointment.email.present?
      Rails.logger.warn "AppointmentMailJob: No email address for appointment ID #{appointment_id}"
      return
    end
    
    Rails.logger.info "Sending confirmation email for appointment ID #{appointment_id} to #{appointment.email}"
    
    AppointmentMailer.confirmed(appointment).deliver_now
    
    Rails.logger.info "Confirmation email sent successfully for appointment ID #{appointment_id}"
    
  rescue StandardError => e
    Rails.logger.error "Failed to send confirmation email for appointment ID #{appointment_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end