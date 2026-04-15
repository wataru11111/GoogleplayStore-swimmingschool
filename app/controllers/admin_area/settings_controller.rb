class AdminArea::SettingsController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :verify_authenticity_token, only: [:add_slot, :delete_slot, :add_slot_off, :delete_slot_off]
  
  def index
    @available_off_day       = Setting.find_by(key: 'available_off_day')&.value
    @available_transfer_day  = Setting.find_by(key: 'available_transfer_day')&.value
    @disabled_transfer_days  = Setting.find_by(key: 'disabled_transfer_days')&.value
    @disabled_transfer_slots = Setting.find_by(key: 'disabled_transfer_slots')&.value
    @disabled_off_slots      = Setting.find_by(key: 'disabled_off_slots')&.value
  end

  def update
    Setting.find_or_initialize_by(key: 'available_off_day')
           .update(value: params[:available_off_day])
    Setting.find_or_initialize_by(key: 'available_transfer_day')
           .update(value: params[:available_transfer_day])

    # 旧形式も念のため保持（後方互換性のため）
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

    redirect_to admin_area_settings_path, notice: '設定を更新しました'
  end

  def add_slot
    slots_json = Setting.find_by(key: 'disabled_transfer_slots')&.value || '[]'
    slots = JSON.parse(slots_json) rescue []
    
    new_slot = {
      'date' => params[:date],
      'type' => params[:slot_type]
    }
    
    if params[:slot_type] == 'time_range'
      new_slot['start_time'] = params[:start_time]
      new_slot['end_time'] = params[:end_time]
    end
    
    slots << new_slot
    Setting.find_or_initialize_by(key: 'disabled_transfer_slots').update(value: slots.to_json)
    
    render json: { success: true, slots: slots }
  end

  def delete_slot
    slots_json = Setting.find_by(key: 'disabled_transfer_slots')&.value || '[]'
    slots = JSON.parse(slots_json) rescue []

    remove_slot_by_payload!(slots, params)
    if params[:date].blank? && params[:type].blank?
      index = params[:index].to_i
      slots.delete_at(index) if index >= 0 && index < slots.length
    end
    
    Setting.find_or_initialize_by(key: 'disabled_transfer_slots').update(value: slots.to_json)
    
    render json: { success: true, slots: slots }
  end

  def add_slot_off
    slots_json = Setting.find_by(key: 'disabled_off_slots')&.value || '[]'
    slots = JSON.parse(slots_json) rescue []
    
    new_slot = {
      'date' => params[:date],
      'type' => params[:slot_type]
    }
    
    if params[:slot_type] == 'time_range'
      new_slot['start_time'] = params[:start_time]
      new_slot['end_time'] = params[:end_time]
    end
    
    slots << new_slot
    Setting.find_or_initialize_by(key: 'disabled_off_slots').update(value: slots.to_json)
    
    render json: { success: true, slots: slots }
  end

  def delete_slot_off
    slots_json = Setting.find_by(key: 'disabled_off_slots')&.value || '[]'
    slots = JSON.parse(slots_json) rescue []

    remove_slot_by_payload!(slots, params)
    if params[:date].blank? && params[:type].blank?
      index = params[:index].to_i
      slots.delete_at(index) if index >= 0 && index < slots.length
    end
    
    Setting.find_or_initialize_by(key: 'disabled_off_slots').update(value: slots.to_json)
    
    render json: { success: true, slots: slots }
  end

  private

  def normalize_dates_str(raw)
    raw.to_s
       .split(/[\s,、，]+/)
       .map { |s| Date.parse(s).strftime('%Y-%m-%d') rescue nil }
       .compact.uniq.sort.join(',')
  end

  def remove_slot_by_payload!(slots, payload)
    date = payload[:date].to_s
    type = payload[:type].to_s
    start_time = payload[:start_time].to_s
    end_time = payload[:end_time].to_s

    return if date.blank? || type.blank?

    index = slots.find_index do |slot|
      next false unless slot.is_a?(Hash)

      slot['date'].to_s == date &&
        slot['type'].to_s == type &&
        slot['start_time'].to_s == start_time &&
        slot['end_time'].to_s == end_time
    end

    slots.delete_at(index) if index
  end
end
