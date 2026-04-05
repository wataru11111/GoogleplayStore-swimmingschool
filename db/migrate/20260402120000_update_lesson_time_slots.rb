class UpdateLessonTimeSlots < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      UPDATE children
      SET
        contact_time1 = CASE
          WHEN contact_dey1 = '水曜日' AND contact_time1 = '14:30' THEN '15:15'
          WHEN contact_dey1 = '水曜日' AND contact_time1 = '15:15' THEN '16:00'
          WHEN contact_dey1 = '水曜日' AND contact_time1 = '19:30' THEN NULL
          WHEN contact_dey1 = '木曜日' AND contact_time1 = '14:30' THEN '14:10'
          WHEN contact_dey1 = '木曜日' AND contact_time1 = '15:00' THEN '14:50'
          WHEN contact_dey1 = '土曜日' AND contact_time1 = '16:00' THEN '16:30'
          WHEN contact_dey1 = '土曜日' AND contact_time1 = '17:00' THEN '17:30'
          WHEN contact_dey1 = '土曜日' AND contact_time1 = '18:00' THEN '18:30'
          ELSE contact_time1
        END,
        contact_time2 = CASE
          WHEN contact_dey2 = '水曜日' AND contact_time2 = '14:30' THEN '15:15'
          WHEN contact_dey2 = '水曜日' AND contact_time2 = '15:15' THEN '16:00'
          WHEN contact_dey2 = '水曜日' AND contact_time2 = '19:30' THEN NULL
          WHEN contact_dey2 = '木曜日' AND contact_time2 = '14:30' THEN '14:10'
          WHEN contact_dey2 = '木曜日' AND contact_time2 = '15:00' THEN '14:50'
          WHEN contact_dey2 = '土曜日' AND contact_time2 = '16:00' THEN '16:30'
          WHEN contact_dey2 = '土曜日' AND contact_time2 = '17:00' THEN '17:30'
          WHEN contact_dey2 = '土曜日' AND contact_time2 = '18:00' THEN '18:30'
          ELSE contact_time2
        END
    SQL

    execute <<~SQL
      UPDATE offs
      SET
        contact_time1 = CASE
          WHEN contact_dey1 = '水曜日' AND contact_time1 = '14:30' THEN '15:15'
          WHEN contact_dey1 = '水曜日' AND contact_time1 = '15:15' THEN '16:00'
          WHEN contact_dey1 = '水曜日' AND contact_time1 = '19:30' THEN NULL
          WHEN contact_dey1 = '木曜日' AND contact_time1 = '14:30' THEN '14:10'
          WHEN contact_dey1 = '木曜日' AND contact_time1 = '15:00' THEN '14:50'
          WHEN contact_dey1 = '土曜日' AND contact_time1 = '16:00' THEN '16:30'
          WHEN contact_dey1 = '土曜日' AND contact_time1 = '17:00' THEN '17:30'
          WHEN contact_dey1 = '土曜日' AND contact_time1 = '18:00' THEN '18:30'
          ELSE contact_time1
        END,
        contact_time2 = CASE
          WHEN contact_dey2 = '水曜日' AND contact_time2 = '14:30' THEN '15:15'
          WHEN contact_dey2 = '水曜日' AND contact_time2 = '15:15' THEN '16:00'
          WHEN contact_dey2 = '水曜日' AND contact_time2 = '19:30' THEN NULL
          WHEN contact_dey2 = '木曜日' AND contact_time2 = '14:30' THEN '14:10'
          WHEN contact_dey2 = '木曜日' AND contact_time2 = '15:00' THEN '14:50'
          WHEN contact_dey2 = '土曜日' AND contact_time2 = '16:00' THEN '16:30'
          WHEN contact_dey2 = '土曜日' AND contact_time2 = '17:00' THEN '17:30'
          WHEN contact_dey2 = '土曜日' AND contact_time2 = '18:00' THEN '18:30'
          ELSE contact_time2
        END
    SQL

    execute <<~SQL
      UPDATE transfers
      SET transfer_time = CASE
        WHEN contact_dey = '水曜日' AND transfer_time = '14:30' THEN '15:15'
        WHEN contact_dey = '水曜日' AND transfer_time = '15:15' THEN '16:00'
        WHEN contact_dey = '木曜日' AND transfer_time = '14:30' THEN '14:10'
        WHEN contact_dey = '木曜日' AND transfer_time = '15:00' THEN '14:50'
        WHEN contact_dey = '土曜日' AND transfer_time = '16:00' THEN '16:30'
        WHEN contact_dey = '土曜日' AND transfer_time = '17:00' THEN '17:30'
        WHEN contact_dey = '土曜日' AND transfer_time = '18:00' THEN '18:30'
        ELSE transfer_time
      END
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "時間帯変更データの完全な復元はできません"
  end
end
