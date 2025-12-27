class AppointmentMailer < ApplicationMailer
  default from: "no-reply@example.com"

  def confirmed(appointment)
    @appointment = appointment
    @slot = appointment.slot
    @branch = appointment.branch
    @appointment_type = appointment.appointment_type
    @reception_number = appointment.id.to_s.rjust(6, '0')

    mail(
      to: appointment.email,
      subject: "【JAふじ伊豆】ご予約を承りました（受付番号: #{@reception_number}）"
    )
  end
end