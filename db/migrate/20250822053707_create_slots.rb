class CreateSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :slots do |t|
      t.references :branch, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :capacity, null: false, default: 1
      t.integer :booked_count, null: false, default: 0

      t.timestamps
    end
    
    add_index :slots, [:branch_id, :starts_at], unique: true
  end
end
