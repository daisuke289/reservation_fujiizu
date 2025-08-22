class CreateBranches < ActiveRecord::Migration[8.0]
  def change
    create_table :branches do |t|
      t.references :area, null: false, foreign_key: true
      t.string :name
      t.string :address
      t.string :phone
      t.text :open_hours

      t.timestamps
    end
  end
end
