# frozen_string_literal: true

class DeviseCreateCustomers < ActiveRecord::Migration[6.1]
  def change
    create_table :customers do |t|
      ## Database authenticatable
      t.string "last_name"
      t.string "first_name"
      t.string "last_name_kana"
      t.string "first_name_kana"
      t.string "postal_code"
      t.string "address"
      t.string "telephone_number"
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## 状態管理
      t.integer :status, null: false, default: 0 # 0: 有効, 1: 休会中, 2: 無効

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.timestamps null: false
    end

    add_index :customers, :email, unique: true
    add_index :customers, :reset_password_token, unique: true
  end
end
