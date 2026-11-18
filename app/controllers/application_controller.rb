# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :suppress_unnecessary_login_flash
  # 新規登録およびログイン後のリダイレクト先を設定
  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      sign_out(:customer) # 他のリソース（顧客）がログインしている場合はサインアウト
      admin_path          # 管理者の場合は管理者トップページにリダイレクト
    elsif resource.is_a?(Customer)
      customers_show_path # 顧客の場合はマイページにリダイレクト
    else
      super               # それ以外の場合はデフォルトのリダイレクト先
    end
  end

  # ログアウト後のリダイレクト先を設定
  def after_sign_out_path_for(resource)
    if resource == :admin
      new_admin_session_path # 管理者ログアウト後のリダイレクト先
    else
      root_path             # 顧客ログアウト後のリダイレクト先
    end
  end

  private

  def suppress_unnecessary_login_flash
    # 正常ログイン・ログイン済みの通知だけを対象にする
    known_messages = [
      "ログインしました。",
      "すでにログインしています。",
      "Signed in successfully.",
      "You are already signed in."
    ]

    # Deviseの翻訳が存在する場合も対応
    translation_keys = [
      "devise.sessions.signed_in",
      "devise.sessions.admin.signed_in",
      "devise.sessions.customer.signed_in",
      "devise.failure.already_authenticated",
      "devise.failure.customer.already_authenticated",
      "devise.failure.admin.already_authenticated"
    ]

    translation_keys.each do |key|
      if I18n.exists?(key, I18n.locale)
        known_messages << I18n.t(key)
      end
    end

    [:notice, :alert].each do |type|
      message = flash[type]
      next unless message.is_a?(String)

      normalized = message.strip

      # 日本語翻訳が未設定だった場合の表示にも対応
      missing_translation =
        normalized.start_with?(
          "Translation missing. Options considered were:"
        ) && (
          normalized.include?("devise.sessions.signed_in") ||
          normalized.include?("devise.failure.already_authenticated")
        )

      if known_messages.include?(normalized) || missing_translation
        flash.delete(type)
      end
    end
  end

end
