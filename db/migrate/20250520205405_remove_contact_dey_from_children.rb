class RemoveContactDeyFromChildren < ActiveRecord::Migration[7.1]
  def change
    remove_column :children, :contact_dey, :string
  end
end
