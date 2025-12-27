class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.references :branch, null: false, foreign_key: true
      t.references :slot, null: false, foreign_key: true
      t.references :appointment_type, null: false, foreign_key: true
      t.string :name, null: false
      t.string :furigana, null: false
      t.string :phone, null: false
      t.string :email
      t.integer :party_size, null: false, default: 1
      t.text :purpose
      t.text :notes
      t.boolean :accept_privacy, null: false, default: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    
    # 同一電話番号・同一日での重複予約を防ぐためのユニークインデックス
    add_index :appointments, [:phone, :slot_id], unique: true
  end
end
