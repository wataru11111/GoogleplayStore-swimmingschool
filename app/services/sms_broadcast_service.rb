class SmsBroadcastService
  Result = Struct.new(:number, :status, :sid, :error_code, :error_message, keyword_init: true)

  def initialize(client: default_client)
    @client = client
  end

  def broadcast(numbers, body)
    numbers.uniq.filter_map do |raw|
      e164 = normalize_e164(raw)
      next if e164.nil?
      begin
        msg = @client.messages.create(message_params(e164, body))
        Result.new(number: e164, status: msg.status, sid: msg.sid)
      rescue ::Twilio::REST::RestError => e
        Result.new(number: e164, status: 'failed', sid: nil, error_code: e.code, error_message: e.message)
      end
    end
  end

  private

  def default_client
    sid = ENV['TWILIO_ACCOUNT_SID']
    token = ENV['TWILIO_AUTH_TOKEN']
    return NullClient.new if sid.blank? || token.blank?
    ::Twilio::REST::Client.new(sid, token)
  end

  def message_params(to, body)
    params = { to: to, body: body }
    if (svc = ENV['TWILIO_MESSAGING_SERVICE_SID']).present?
      params[:messaging_service_sid] = svc
    else
      params[:from] = ENV['TWILIO_FROM_NUMBER']
    end
    params
  end

  def normalize_e164(raw)
    return nil if raw.blank?
    digits = raw.gsub(/[^0-9]/, '')
    return nil if digits.blank?
    digits.sub!(/^0+/, '')
    "+81#{digits}"
  end

  # Fallback client when credentials missing
  class NullClient
    def messages
      self
    end

    def create(*)
      OpenStruct.new(status: 'skipped', sid: nil)
    end
  end
end
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
