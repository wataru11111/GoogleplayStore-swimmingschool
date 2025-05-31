class Admin::SettingsController < ApplicationController
  def index
    @available_off_day = Setting.find_by(key: 'available_off_day')&.value
    @available_transfer_day = Setting.find_by(key: 'available_transfer_day')&.value
  end

  def update
    Setting.find_or_initialize_by(key: 'available_off_day').update(value: params[:available_off_day])
    Setting.find_or_initialize_by(key: 'available_transfer_day').update(value: params[:available_transfer_day])
    redirect_to admin_settings_path, notice: '登録可能な最終日を更新しました'
  end

end

