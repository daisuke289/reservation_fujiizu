class AddAdminMemoToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :admin_memo, :text
  end
end
