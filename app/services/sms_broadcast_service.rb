class SmsBroadcastService
  # SMSプロバイダ: Twilio を想定
  # 必要な環境変数: TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM_NUMBER

  def initialize(from: ENV['TWILIO_FROM_NUMBER'])
    require 'twilio-ruby'
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    # from が Messaging Service SID ("MG...") の場合に対応
    if from.to_s.start_with?('MG')
      @messaging_service_sid = from
    else
      @from = from
    end
  end

  # recipients: 電話番号文字列の配列（ハイフンなし推奨、国番号付き推奨）
  # body: 送信する本文
  # 戻り値: 成功/失敗の配列 [{to:, sid:, status:} ...]
  def broadcast(recipients:, body:)
    results = []
    recipients.uniq.compact.each do |to|
      next if to.to_s.strip.empty?

      begin
        params = { to: normalize_e164(to), body: body }
        if @messaging_service_sid
          params[:messaging_service_sid] = @messaging_service_sid
        else
          params[:from] = @from
        end

  # Ruby 3 以降はキーワード引数として渡す必要があるため **params を使用
  msg = @client.messages.create(**params)
        results << { to: to, sid: msg.sid, status: (msg.status || 'queued') }
      rescue Twilio::REST::RestError => e
        # Twilio固有のエラーコードも含めて返す
        results << { to: to, error: e.message, code: e.code, status: 'failed' }
      rescue => e
        results << { to: to, error: e.message, status: 'failed' }
      end
    end
    results
  end

  private

  # 国内番号をE.164に正規化（例: 070xxxxxxxx -> +8170xxxxxxxx）。
  # ここでは日本(+81)を既定とします。必要なら国別ロジックに拡張。
  def normalize_e164(number)
    num = number.to_s.gsub(/\D/, '')
    if num.start_with?('0')
      "+81" + num[1..]
    elsif num.start_with?('+')
      number
    else
      "+#{num}"
    end
  end
end
