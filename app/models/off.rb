class Off < ApplicationRecord
  belongs_to :child
  has_many :transfers, foreign_key: :off_id

  before_validation :normalize_contact_times
  validate :prevent_duplicate_off_month, on: :public

  # ✅ contextが:publicのときだけバリデーションを適用

  # ✅ コールバックも public だけ
  before_create :check_expiration_on_create, if: :validate_public_context?

  # 振替済みかどうかを判定するメソッド
  def transfer_registered?
    transfers.exists?
  end

  # 振替済みのTransferデータを取得するメソッド
  def registered_transfer
    transfers.first
  end

  # 振替データが関連付けられていない場合、flagをデフォルトの状態に戻す
  def reset_flag_if_no_transfer
    if transfers.empty? && flag != 0
      update(flag: 0)
    end
  end

  # 振替エラー時にflagをリセットするメソッド
  def reset_flag
    self.update(flag: 0)
  end

  # 期限切れを判定するメソッド
  def expired?
    off_month && off_month < 3.months.ago.to_date
  end

  # 期限切れをチェックしてフラグを更新するメソッド
  def check_and_update_expiration
    if expired? && flag == 0
      update(flag: 2)
    end
  end

  # 保存前に期限切れをチェックしてフラグを設定する
  private

  def check_expiration_on_create
    self.flag = 2 if expired? && self.flag == 0
  end

 # ✅ contextが :public のときのみ true
  def validate_public_context?
    validation_context == :public || validation_context.nil?
  end

  def prevent_duplicate_off_month
    return if child_id.blank? || off_month.blank?

    duplicate = Off.where(
      child_id: child_id,
      off_month: off_month
    )
    duplicate = duplicate.where.not(id: id) if persisted?

    if duplicate.exists?
      errors.add(
        :base,
        "この日は既に登録されています。\n別の日にちを指定してください。"
      )
    end
  end

  # DUPLICATE_MESSAGE_SINGLE_20261118

  def normalize_contact_times
    self.contact_time1 = TimeSlotNormalizer.normalize_contract_time(contact_dey1, contact_time1)
    self.contact_time2 = TimeSlotNormalizer.normalize_contract_time(contact_dey2, contact_time2)
  end
end
