# app/controllers/admin/settings_controller.rb
class Admin::SettingsController < ApplicationController
  def index
    @available_off_day       = Setting.find_by(key: 'available_off_day')&.value
    @available_transfer_day  = Setting.find_by(key: 'available_transfer_day')&.value
    @disabled_transfer_days  = Setting.find_by(key: 'disabled_transfer_days')&.value # ←追加
    # （必要なら）お休み側も：@disabled_off_days = Setting.find_by(key: 'disabled_off_days')&.value
  end

  def update
    Setting.find_or_initialize_by(key: 'available_off_day')
           .update(value: params[:available_off_day])
    Setting.find_or_initialize_by(key: 'available_transfer_day')
           .update(value: params[:available_transfer_day])

    # ↓ 追加：カンマ/空白/改行/読点 で区切って YYYY-MM-DD に正規化して保存
    if params[:disabled_transfer_days].present?
      normalized = normalize_dates_str(params[:disabled_transfer_days])
      Setting.find_or_initialize_by(key: 'disabled_transfer_days').update(value: normalized)
    else
      Setting.find_or_initialize_by(key: 'disabled_transfer_days').update(value: "")
    end

     
     if params[:disabled_off_days].present?
       Setting.find_or_initialize_by(key: 'disabled_off_days').update(value: normalize_dates_str(params[:disabled_off_days]))
     else
       Setting.find_or_initialize_by(key: 'disabled_off_days').update(value: "")
     end

    redirect_to admin_settings_path, notice: '設定を更新しました'
  end

  private

  def normalize_dates_str(raw)
    raw.to_s
       .split(/[\s,、，]+/)                           # 空白/カンマ/読点を区切りに
       .map { |s| Date.parse(s).strftime('%Y-%m-%d') rescue nil }
       .compact.uniq.sort.join(',')                  # YYYY-MM-DD のCSVに統一
  end
end


