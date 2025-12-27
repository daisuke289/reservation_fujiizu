class AddCodeToBranches < ActiveRecord::Migration[8.0]
  def change
    add_column :branches, :code, :string
    add_index :branches, :code, unique: true
  end
end
