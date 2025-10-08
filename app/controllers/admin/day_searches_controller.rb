class Admin::DaySearchesController < ApplicationController
  before_action :authenticate_admin!

  def index
    @search = ContractDaySearch.new(day: params[:day])
    @children = params[:day].present? && @search.valid? ? @search.results : []
  end

  def broadcast_sms
    search = ContractDaySearch.new(day: params[:day])
    children = search.results

    numbers = children.map { |c| c.customer&.telephone_number.presence || c.telephone_number }.compact

    if numbers.empty?
      redirect_to admin_day_searches_path(day: params[:day]), alert: '送信対象の電話番号がありません。' and return
    end

    body = params[:body].presence || 'スイミングスクールよりお知らせです。'
    results = SmsBroadcastService.new.broadcast(recipients: numbers, body: body)

    success = results.select { |r| r[:status] != 'failed' }
    failed  = results.select { |r| r[:status] == 'failed' }

    # ログに詳細を残す
    Rails.logger.info("[SMS Broadcast] total=#{results.size} success=#{success.size} failed=#{failed.size}")
    failed.each { |f| Rails.logger.warn("[SMS Broadcast][FAILED] to=#{f[:to]} code=#{f[:code]} error=#{f[:error]}") }

    if failed.any?
      detail = failed.map { |f| f[:to] + (f[:code] ? "(code=#{f[:code]})" : '') }.join(', ')
      msg = "SMS送信: 成功#{success.size}件 / 失敗#{failed.size}件。失敗先: #{detail}"
      redirect_to admin_day_searches_path(day: params[:day]), alert: msg
    else
      redirect_to admin_day_searches_path(day: params[:day]), notice: "#{success.size}件のSMSを送信キューに投入しました。"
    end
  end

  # 選択した曜日の在籍者（保護者 = Customer）にPush通知をワンクリックで配信（テンプレ文面）
  def broadcast_push
    search = ContractDaySearch.new(day: params[:day])
    unless search.valid?
      redirect_to admin_day_searches_path(day: params[:day]), alert: '曜日を選択してください。' and return
    end

    children = search.results
    customer_ids = children.map(&:customer_id).compact.uniq

    if customer_ids.empty?
      redirect_to admin_day_searches_path(day: params[:day]), alert: '通知対象が見つかりませんでした。' and return
    end

    normalized = ContractDaySearch::DAY_TO_DB.fetch(search.day, search.day)
    title = '休講のお知らせ'
    message = "【重要】本日の#{normalized}クラスは休講となりました。ご迷惑をおかけいたします。振替等の詳細はマイページをご確認ください。"

    OneSignalService.send_to_external_ids(
      title: title,
      message: message,
      external_ids: customer_ids
    )

    redirect_to admin_day_searches_path(day: params[:day]), notice: "Push通知を送信しました（対象: #{customer_ids.size}名）"
  end
end
