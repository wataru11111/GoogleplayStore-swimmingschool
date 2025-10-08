class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :children, dependent: :destroy

  # ステータスの定義
  enum status: { active: 0, suspended: 1, inactive: 2 }

  # 日本語の表示名を定義
  def self.statuses_i18n
    {
      "active" => "有効",
      "suspended" => "休会中",
      "inactive" => "無効"
    }
  end

  # Deviseのログイン制御
  def active_for_authentication?
    super && status != "inactive"
  end

  def inactive_message
    status == "inactive" ? :inactive_account : super
  end

  # バリデーション
  validates :status, presence: true
  validates :last_name, presence: true
  validates :last_name_kana, presence: true
  validates :first_name, presence: true
  validates :first_name_kana, presence: true
  validates :postal_code, presence: true, format: { with: /\A\d{3}-\d{4}\z/, message: "はハイフンを含む7桁で入力してください" }
  validates :address, presence: true
  validates :telephone_number, presence: true, format: { with: /\A\d{10,11}\z/, message: "はハイフンなしの10〜11桁の数字で入力してください" }
end
