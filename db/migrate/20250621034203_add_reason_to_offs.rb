class AddReasonToOffs < ActiveRecord::Migration[7.1]
  def change
    add_column :offs, :reason, :string
  end
end
