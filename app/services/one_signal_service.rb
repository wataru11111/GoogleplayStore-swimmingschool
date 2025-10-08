# app/services/one_signal_service.rb

require 'httparty'

class OneSignalService
  def self.send_notification(title:, message:)
    response = HTTParty.post('https://onesignal.com/api/v1/notifications',
      headers: {
        "Content-Type" => "application/json; charset=utf-8",
        "Authorization" => "Basic #{ENV['ONESIGNAL_API_KEY']}"
      },
      body: {
        app_id: ENV['ONESIGNAL_APP_ID'],
        included_segments: ['All'], # 全購読者に通知
        headings: { en: title },
        contents: { en: message },
        url: "https://wataru11111.github.io/swimming-school-homepage/"
      }.to_json
    )
  end
end
