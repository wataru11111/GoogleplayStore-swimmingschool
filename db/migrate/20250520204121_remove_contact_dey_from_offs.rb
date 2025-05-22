class RemoveContactDeyFromOffs < ActiveRecord::Migration[7.1]
  def change
    remove_column :offs, :contact_dey, :string
  end
end
