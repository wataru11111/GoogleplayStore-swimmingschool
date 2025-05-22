class AddContractTimesToOffs < ActiveRecord::Migration[7.1]
  def change
    add_column :offs, :contact_time1, :string
    add_column :offs, :contact_time2, :string
    add_column :offs, :contact_dey1, :string
    add_column :offs, :contact_dey2, :string
  end
end
