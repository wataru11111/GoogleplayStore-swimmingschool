class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!

  def top
    Rails.logger.debug "✅ Received params: #{params.inspect}" # 🔍 確認用ログ

    if params[:search_date].present?
      begin
        search_date = Date.parse(params[:search_date]) # `string` → `Date型` に変換
      rescue ArgumentError
        search_date = nil
      end

      Rails.logger.debug "🔍 Parsed search_date: #{search_date}" # 🔍 日付の確認

      # `search_date` が `nil` でない場合のみ検索
      @dates = search_date ? Transfer.where(transfer_date: search_date) : Transfer.none
      Rails.logger.debug "📊 Found transfers: #{@dates.count}" # 🔍 データ件数の確認

      # ✅ クラスごとの振替人数を集計
      @class_counts = @dates.group(:level).count

      # ✅ 上限3人から差し引いて残り枠数を算出
      @class_slots = @class_counts.transform_values { |count| 3 - count }

    else
      @dates = Transfer.all
      @class_counts = {}
      @class_slots = {}
    end

    @offs = Off.all # お休み情報の取得は変更なし
  end
end

