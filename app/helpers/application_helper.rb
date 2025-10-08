module ApplicationHelper
	# 日本の携帯番号を簡易的にE.164形式へ正規化（例: 090xxxx -> +8190xxxx）
	# すでに+81や+で始まる場合は尊重します。
	def e164_jp(number)
		num = number.to_s.gsub(/\D/, '')
		return '' if num.empty?

		if num.start_with?('0')
			"+81" + num[1..]
		elsif num.start_with?('81') && num.length > 2
			"+#{num}"
		elsif number.to_s.start_with?('+')
			number
		else
			"+#{num}"
		end
	end

	# sms:URI を生成（本文はURLエンコード）
	# 一部端末では body パラメータが無視されることがあります。
	def sms_href(number, body = '')
		n = e164_jp(number)
		return nil if n.blank?
		b = ERB::Util.url_encode(body.to_s)
		"sms:#{n}?&body=#{b}"
	end
end
