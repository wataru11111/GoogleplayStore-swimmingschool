class RemoveContactTimeFromChildren < ActiveRecord::Migration[7.1]
  def change
    remove_column :children, :contact_time, :string
  end
end
