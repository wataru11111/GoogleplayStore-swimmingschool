class ContractDaySearch
  include ActiveModel::Model

  attr_accessor :day

  WEEKDAYS = %w[月 火 水 木 金 土 日].freeze
  DAY_TO_DB = {
    '月' => '月', '火' => '火', '水' => '水', '木' => '木', '金' => '金', '土' => '土', '日' => '日'
  }.freeze

  validates :day, presence: true, inclusion: { in: WEEKDAYS }

  def results
    return Child.none unless valid?
    db_day = DAY_TO_DB[day]
    # contact_dey1 / 2 のいずれかに一致
    Child.includes(:customer)
         .where('contact_dey1 = :d OR contact_dey2 = :d', d: db_day)
         .order(Arel.sql('children.last_name_kana IS NULL, children.last_name_kana ASC, children.first_name_kana ASC'))
  end
end
class ContractDaySearch
  include ActiveModel::Model

  # 入力パラメータ
  attr_accessor :day

  # 画面で選べる曜日（短縮表記）
  WEEKDAYS = %w[月 火 水 木 金 土 日].freeze

  # 画面入力をDB保存の表記へ正規化するマップ
  DAY_TO_DB = {
    "月" => "月曜日", "火" => "火曜日", "水" => "水曜日",
    "木" => "木曜日", "金" => "金曜日", "土" => "土曜日", "日" => "日曜日",
    # 補助: 既にフル表記/祝日が来てもそのまま扱えるように
    "月曜日" => "月曜日", "火曜日" => "火曜日", "水曜日" => "水曜日",
    "木曜日" => "木曜日", "金曜日" => "金曜日", "土曜日" => "土曜日", "日曜日" => "日曜日",
    "祝" => "祝日", "祝日" => "祝日"
  }.freeze

  validates :day, presence: true, inclusion: { in: WEEKDAYS }

  # 検索結果（ActiveRecord::Relation）
  def results
    return Child.none unless valid?

    normalized = DAY_TO_DB.fetch(day, day)

    relation = Child.includes(:customer)
        .where("contact_dey1 = :d OR contact_dey2 = :d", d: normalized)
        .order(:last_name_kana, :first_name_kana)

    # 念のため、完全一致で0件なら接頭辞一致でも再検索（例: DB が「土曜」などの場合）
    return relation if relation.exists?

    prefix = normalized.to_s[0]
    Child.includes(:customer)
      .where("contact_dey1 LIKE :p OR contact_dey2 LIKE :p", p: "#{prefix}%")
      .order(:last_name_kana, :first_name_kana)
  end
end
