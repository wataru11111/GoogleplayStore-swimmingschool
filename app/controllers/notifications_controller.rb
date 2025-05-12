class NotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def update_notice
  Rails.logger.info "📥 受信したAuthorizationヘッダー: #{request.headers['Authorization']}"
  expected = "Bearer #{ENV['INTERNAL_NOTIFY_TOKEN']}"
  Rails.logger.info "🔐 比較対象: #{expected}"

  return head :unauthorized unless request.headers['Authorization'] == expected

  title = params[:title] || "お知らせが更新されました"
  message = params[:message] || "新しいスケジュールが公開されました"
  OneSignalService.send_notification(title: title, message: message)

  head :ok
end

