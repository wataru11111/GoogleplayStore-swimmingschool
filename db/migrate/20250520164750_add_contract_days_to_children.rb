class AddContractDaysToChildren < ActiveRecord::Migration[7.1]
  def change
    add_column :children, :contact_dey1, :string
    add_column :children, :contact_dey2, :string
  end
end
