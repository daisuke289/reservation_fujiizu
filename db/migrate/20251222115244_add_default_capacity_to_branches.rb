class AddDefaultCapacityToBranches < ActiveRecord::Migration[8.0]
  def change
    add_column :branches, :default_capacity, :integer, default: 1, null: false
  end
end
