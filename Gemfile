source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

# --- Rails & DB関連 ---
gem 'rails', '~> 7.1.3'

group :development, :test do
  gem 'sqlite3', '~> 1.4'
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
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  gem 'webdrivers'
end

