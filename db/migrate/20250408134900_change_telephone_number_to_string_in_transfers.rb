class ChangeTelephoneNumberToStringInTransfers < ActiveRecord::Migration[6.1]
  def change
   change_column :transfers, :telephone_number, :string
  end
end
