class AddContractTimesToChildren < ActiveRecord::Migration[7.1]
  def change
    add_column :children, :contact_time1, :string
    add_column :children, :contact_time2, :string
  end
end
