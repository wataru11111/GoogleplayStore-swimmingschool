class ScheduleOverrides
  # ADMIN_ADDITIONAL_DAYS_20261118
  # 設定テーブルへJSONで保存。マイグレーション不要。
  TRANSFER_KEY = "additional_transfer_days"
  OFF_KEY = "additional_off_days"
  WEEKDAYS = %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日].freeze

  # ADMIN_TRANSFER_TIME_SLOTS_20261119
  # 新形式 {"2026-11-25":["11:00","11:30"]} を使用。
  # 旧形式の配列は時間未設定として保持し、再設定するまで新規振替を不可にする。
  def self.transfer_schedule
    data = JSON.parse(Setting.find_by(key: TRANSFER_KEY)&.value.presence || "[]")

    if data.is_a?(Array)
      return data.select { |day| day.is_a?(String) }
                 .to_h { |day| [day, []] }
    end
    raise ArgumentError, "振替追加日の保存形式が不正です" unless data.is_a?(Hash)

    data.transform_values do |times|
      values = times.is_a?(Array) ? times : []
      valid = values.map(&:to_s).uniq.sort
      valid.length.between?(1, 6) && (valid - TransferCalendar::HOLIDAY_TIMES).empty? ? valid : []
    end
  end

  def self.transfer_dates
    transfer_schedule.select { |_day, times| times.any? }.keys.sort
  end

  def self.transfer_all_dates
    transfer_schedule.keys.sort
  end

  def self.transfer_slots_for(date)
    day = date.respond_to?(:iso8601) ? date.iso8601 : date.to_s
    transfer_schedule.fetch(day, [])
  end

  def self.off_entries
    JSON.parse(Setting.find_by(key: OFF_KEY)&.value.presence || "[]")
  end

  def self.off_for?(date, child)
    return false unless date && child

    contracted = [child.contact_dey1, child.contact_dey2].compact.map(&:strip)
    off_entries.any? do |entry|
      entry.is_a?(Hash) && entry["date"] == date.iso8601 &&
        contracted.include?(entry["contract_weekday"])
    end
  end

  def self.add_transfer!(date, times)
    raise ArgumentError, "土日は通常時間割を利用してください" if date.saturday? || date.sunday?

    selected = Array(times).map { |t| t.to_s.strip }.reject(&:blank?).uniq.sort
    unless selected.size.between?(1, 6) && (selected - TransferCalendar::HOLIDAY_TIMES).empty?
      raise ArgumentError, "11:00〜19:30の30分刻みから1〜6枠を選択してください"
    end

    current = transfer_schedule
    current[date.iso8601] = selected  # 既存日付は時間を丸ごと更新
    Setting.find_or_initialize_by(key: TRANSFER_KEY).update!(value: current.sort.to_h.to_json)
  end

  def self.remove_transfer!(date)
    current = transfer_schedule
    current.delete(date.iso8601)
    Setting.find_or_initialize_by(key: TRANSFER_KEY).update!(value: current.sort.to_h.to_json)
  end

  def self.add_off!(date, weekday)
    raise ArgumentError, "契約曜日が不正です" unless WEEKDAYS.include?(weekday)
    current = off_entries
    entry = { "date" => date.iso8601, "contract_weekday" => weekday }
    current << entry unless current.include?(entry)
    current.sort_by! { |item| [item["date"], item["contract_weekday"]] }
    Setting.find_or_initialize_by(key: OFF_KEY).update!(value: current.to_json)
  end

  def self.remove_off!(date, weekday)
    current = off_entries
    current.reject! { |item| item["date"] == date.iso8601 && item["contract_weekday"] == weekday }
    Setting.find_or_initialize_by(key: OFF_KEY).update!(value: current.to_json)
  end
end
