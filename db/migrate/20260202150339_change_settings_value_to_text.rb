class ChangeSettingsValueToText < ActiveRecord::Migration[7.1]
  def change
    change_column :settings, :value, :text
  end
end
