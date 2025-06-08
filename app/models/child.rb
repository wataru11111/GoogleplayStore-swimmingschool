class Child < ApplicationRecord
  belongs_to :customer
  has_many :transfer
  has_many :offs

# ✅ バリデーションをここに追加
 # validate :different_contract_days_if_two

# def different_contract_days_if_two
   # if contact_dey1.present? && contact_dey2.present? && contact_dey1 == contact_dey2
    #  errors.add(:contact_dey2, "は契約曜日1と異なる曜日を選んでください")
   # end
  #end
end
