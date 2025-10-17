module ApplicationHelper
	# 日本の電話番号を E.164 (+81) 形式へ簡易変換
	def e164_jp(raw)
		return nil if raw.blank?
		digits = raw.to_s.gsub(/[^0-9]/, '')
		return nil if digits.blank?
		# 先頭0を削除して +81 を付与 (国内携帯など想定)
		digits.sub!(/^0+/, '')
		"+81#{digits}"
	end

	# sms: スキームの href を生成 (iOS/Android でやや挙動差があるため &body=)
	def sms_href(number, body = '')
		e164 = e164_jp(number)
		return '#' unless e164
		encoded = CGI.escape(body.to_s)
		"sms:#{e164}?&body=#{encoded}"
	end
end
