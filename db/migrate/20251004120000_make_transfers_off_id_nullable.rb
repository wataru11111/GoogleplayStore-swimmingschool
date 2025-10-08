class MakeTransfersOffIdNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :transfers, :off_id, true
  end
end
