class Child < ApplicationRecord
  belongs_to :customer
  has_many :transfer
  has_many :offs

  before_validation :normalize_contact_times

  # フルネームを返すメソッド
  def full_name
    "#{last_name} #{first_name}"
  end

  private

  def normalize_contact_times
    self.contact_time1 = TimeSlotNormalizer.normalize_contract_time(contact_dey1, contact_time1)
    self.contact_time2 = TimeSlotNormalizer.normalize_contract_time(contact_dey2, contact_time2)
  end

# ✅ バリデーションをここに追加
 # validate :different_contract_days_if_two

# def different_contract_days_if_two
   # if contact_dey1.present? && contact_dey2.present? && contact_dey1 == contact_dey2        
    #  errors.add(:contact_dey2, "は契約曜日1と異なる曜日を選んでください")
   # end
  #end
end
