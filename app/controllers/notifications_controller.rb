class NotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def update_notice
    return head :unauthorized unless request.headers['Authorization'] == "Bearer #{ENV['INTERNAL_NOTIFY_TOKEN']}"

    title = params[:title] || "お知らせが更新されました"
    message = params[:message] || "新しいスケジュールが公開されています"

    OneSignalService.send_notification(title: title, message: message)

    head :ok
  end
end
