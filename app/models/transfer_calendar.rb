class TransferCalendar
  # 内閣府公表の2026年・2027年の祝日・休日
  HOLIDAY_DATES = %w[
    2026-01-01 2026-01-12 2026-02-11 2026-02-23
    2026-03-20 2026-04-29 2026-05-03 2026-05-04
    2026-05-05 2026-05-06 2026-07-20 2026-08-11
    2026-09-21 2026-09-22 2026-09-23 2026-10-12
    2026-11-03 2026-11-23
    2027-01-01 2027-01-11 2027-02-11 2027-02-23
    2027-03-21 2027-03-22 2027-04-29 2027-05-03
    2027-05-04 2027-05-05 2027-07-19 2027-08-11
    2027-09-20 2027-09-23 2027-10-11 2027-11-03
    2027-11-23
  ].freeze

  HOLIDAY_TIMES = (660..1170).step(30).map do |minutes|
    format("%02d:%02d", minutes / 60, minutes % 60)
  end.freeze

  TIME_OPTIONS = {
    "土曜日" => %w[16:30 17:30 18:30],
    "日曜日" => %w[12:00 13:00 14:00 17:00],
    "祝日" => HOLIDAY_TIMES
  }.freeze

  def self.day_for(date)
    return nil unless date

    return "土曜日" if date.saturday?
    return "日曜日" if date.sunday?
    return "祝日" if ScheduleOverrides.transfer_dates.include?(date.iso8601) # ADMIN_ADDITIONAL_DAYS_20261118

    nil
  end

  def self.times_for(day)
    TIME_OPTIONS.fetch(day, [])
  end

  # A3_SLOT_CAPACITY_20261118
  CAPACITY = 3
  LEVEL_ORDER = (
    %w[カニ ラッコ イルカ] +
    %w[黄 青 赤 ピンク].flat_map { |color| (1..4).map { |n| "#{color}星#{n}" } }
  ).freeze

  def self.canonical_level(value)
    name = value.to_s.strip
    return "カニ" if %w[カニ 2歳カニ 3歳カニ].include?(name)
    return "ピンク星4" if name == "ピンク星"
    return "AS" if name == "AS"

    LEVEL_ORDER.include?(name) ? name : nil
  end

  def self.allowed_times_for(day, level, date: nil)
    name = canonical_level(level)
    return [] unless name

    # SWIMMING_AS_CLASS_20261119
    # ASクラスは土曜日18:30、日曜日14:00だけ
    if name == "AS"
      return ["18:30"] if day == "土曜日"
      return ["14:00"] if day == "日曜日"
      return []
    end


    rank = LEVEL_ORDER.index(name)
    case day
    when "土曜日"
      result = ["16:30"]
      result << "17:30" if rank >= LEVEL_ORDER.index("黄星2")
      # 18:30は青星1〜ピンク星4が対象。小学生限定の条件は設けない。
      result << "18:30" if rank >= LEVEL_ORDER.index("青星1")
      result
    when "日曜日"
      result = []
      result << "12:00" if rank <= LEVEL_ORDER.index("赤星4")
      result << "13:00"
      result << "14:00" if rank >= LEVEL_ORDER.index("黄星2")
      result << "17:00"
      result
    when "祝日"
      # A②の管理者設定を入れるまでは既存の祝日時間設定を保持
      date ? ScheduleOverrides.transfer_slots_for(date) : []
    else
      []
    end
  end

  def self.registration_count(date, time, level)
    name = canonical_level(level)
    return 0 unless name
    aliases = case name
    when "カニ" then %w[カニ 2歳カニ 3歳カニ]
    when "ピンク星4" then %w[ピンク星4 ピンク星]
    else [name]
    end
    Transfer.where(transfer_date: date, transfer_time: time, level: aliases).count
  end

end
