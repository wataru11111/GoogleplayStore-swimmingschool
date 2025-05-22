class RemoveContactTimeFromOffs < ActiveRecord::Migration[7.1]
  def change
    remove_column :offs, :contact_time, :string
  end
end
