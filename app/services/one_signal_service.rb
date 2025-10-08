# app/services/one_signal_service.rb

require 'httparty'

class OneSignalService
  API_URL = 'https://onesignal.com/api/v1/notifications'.freeze

  # 全購読者に通知（既存の挙動を維持）
  def self.send_notification(title:, message:, url: "https://wataru11111.github.io/swimming-school-homepage/")
    HTTParty.post(
      API_URL,
      headers: {
        "Content-Type" => "application/json; charset=utf-8",
        "Authorization" => "Basic #{ENV['ONESIGNAL_API_KEY']}"
      },
      body: {
        app_id: ENV['ONESIGNAL_APP_ID'],
        included_segments: ['All'],
        headings: { en: title, ja: title },
        contents: { en: message, ja: message },
        url: url
      }.to_json
    )
  end

  # external_user_ids（OneSignal.login で紐付けたID）宛に限定配信
  # external_ids: Array<String|Integer>
  def self.send_to_external_ids(title:, message:, external_ids:, url: nil)
    ids = Array(external_ids).map(&:to_s).uniq
    return if ids.empty?

    HTTParty.post(
      API_URL,
      headers: {
        "Content-Type" => "application/json; charset=utf-8",
        "Authorization" => "Basic #{ENV['ONESIGNAL_API_KEY']}"
      },
      body: {
        app_id: ENV['ONESIGNAL_APP_ID'],
        include_external_user_ids: ids,
        channel_for_external_user_ids: 'push',
        headings: { en: title, ja: title },
        contents: { en: message, ja: message },
        url: url
      }.to_json
    )
  end
end
