class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!

  def top
    if params[:search_date].present?
      begin
        search_date = Date.parse(params[:search_date])
      rescue ArgumentError
        search_date = nil
      end

      @dates = search_date ? Transfer.where(transfer_date: search_date) : Transfer.none

      # ✅ 時間 × クラスで人数集計（例: {"12:00〜13:00|カニ" => 2}）
      @time_level_counts = @dates.group(:transfer_time, :level).count

      # ✅ 「12:00 カニ 2/3」の表示形式に変換
      @time_level_slots = @time_level_counts.transform_keys do |(time, level)|
        "#{time} #{level}"
      end.transform_values do |count|
        "#{count} / 3"
      end
    else
      @dates = Transfer.all
      @time_level_slots = {}
    end

    @offs = Off.all
  end
end

