class Transfer < ApplicationRecord
  belongs_to :child
  belongs_to :off, foreign_key: :off_id

  # ✅ Public側だけでバリデーションを効かせたい項目
  validates :last_name, presence: { message: "苗字を入力してください。" }, on: :public
  validates :first_name, presence: { message: "名前を入力してください。" }, on: :public
  validates :transfer_date, presence: { message: "振替日を選択してください。" }, on: :public
  validates :level, presence: { message: "クラスを選択してください。" }, on: :public
  validates :contact_dey, presence: { message: "振替曜日を選択してください。" }, on: :public
  validates :transfer_time, presence: { message: "振替時間を選択してください。" }, on: :public
  validates :telephone_number, presence: { message: "電話番号を入力してください。" },
            format: { with: /\A\d{10,11}\z/, message: "電話番号はハイフンなしで入力してください。" }, on: :public

  # ✅ 人数制限バリデーションも public だけ
  validate :limit_transfers_per_time_slot, on: :public

  # ✅ エラー時は関連Offのflagをリセット（全体で使うのでcontext制御なしでOK）
  after_validation :reset_off_flag_on_error, if: -> { errors.any? }

  private

  # ✅ 人数制限のロジック（public専用）
  def limit_transfers_per_time_slot
    if Transfer.where(transfer_date: transfer_date, level: level, transfer_time: transfer_time).count >= 2
      errors.add(:base, "申し訳ございません。その日にちは人数に空きがないため振替ができません。別の日にち、時間帯で試してください。")
    end
  end

  # ✅ エラーがあればOffのflagを戻す
  def reset_off_flag_on_error
    off&.reset_flag
  end
end

