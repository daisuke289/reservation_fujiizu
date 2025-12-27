class AddFieldsToAreas < ActiveRecord::Migration[8.0]
  def change
    add_column :areas, :jurisdiction, :text
    add_column :areas, :display_order, :integer, null: false, default: 0
    add_column :areas, :is_active, :boolean, null: false, default: true

    add_index :areas, :display_order
    add_index :areas, :is_active
  end
end
