source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# もし本当に 3.3.0 固定理由があるなら元に戻すか ruby "3.3.0" にしてください。
ruby "3.3.0"

# --- Rails & DB関連 ---
gem 'rails', '~> 7.1.3'
# --- OneSignal通知API用 ---
gem 'httparty'

# --- SMS 送信用（Twilio） ---
gem 'twilio-ruby'

group :development, :test do
  gem 'sqlite3', '~> 1.4'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Windows では planetscale_rails の rake タスクが 'pty' を要求して落ちるため自動 require を止める
  # Linux/CI 等で必要な場合は、明示的に `require 'planetscale_rails'` してください
  gem "planetscale_rails", require: false
end


group :production do
  gem 'mysql2', '~> 0.5.5', platforms: [:mri]
  gem 'puma-daemon'
end

# --- Webサーバー・アセット管理 ---
gem 'logger', require: false
gem 'puma', '~> 6.0'
gem 'sassc-rails'           # ✅ ここに変更！
gem 'importmap-rails'       # ✅ JS管理用（または下の jsbundling）
gem 'turbo-rails'           # ✅ Turbo導入
gem 'stimulus-rails'        # ✅ Stimulus導入
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.4', require: false

# --- 認証・ページネーションなど ---
gem 'devise'
gem 'kaminari','~> 1.2.1'
gem "enum_help"
gem 'dotenv-rails'

# --- メール関連 ---
gem "net-smtp"
gem "net-pop"
gem "net-imap"

# --- Windows専用 ---
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'wdm', '>= 0.1.0', platforms: [:mswin, :mingw, :x64_mingw]

# --- webrick追加 ---
gem 'webrick', platforms: [:ruby]

# --- 開発用 ---
group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 3.2'
  gem 'listen', '~> 3.7'
  gem 'spring'
  gem 'letter_opener'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  gem 'webdrivers'
end

