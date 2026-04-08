module TimeSlotNormalizer
  LEGACY_TIME_MAPPING = {
    "水曜日" => {
      "14:30" => "15:15",
      "19:30" => nil
    },
    "木曜日" => {
      "14:30" => "14:10",
      "15:00" => "14:50"
    },
    "土曜日" => {
      "16:00" => "16:30",
      "17:00" => "17:30",
      "18:00" => "18:30"
    }
  }.freeze

  module_function

  def normalize_contract_time(day, time)
    return time if day.blank? || time.blank?

    mapping = LEGACY_TIME_MAPPING[day]
    return time unless mapping&.key?(time)

    mapping[time]
  end

  def normalize_transfer_time(day, time)
    return time if day.blank? || time.blank?

    mapping = LEGACY_TIME_MAPPING[day]
    return time unless mapping&.key?(time)

    mapped = mapping[time]
    mapped.presence || time
  end
end
