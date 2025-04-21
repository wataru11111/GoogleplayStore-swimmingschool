source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.3.0"

# --- Rails & DB関連 ---
gem 'rails', '~> 6.1.7', '>= 6.1.7.3'

group :development, :test do
  gem 'sqlite3', '~> 1.4' # ✅ 開発＆テスト用
end

group :production do
  gem 'mysql2', '~> 0.5.5' # ✅ 本番用（PlanetScale用）
end

# --- Webサーバーなど ---
gem 'puma', '~> 3.11'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
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

# --- Windows専用（LinuxやVercelでは不要だが保持してもOK） ---
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'wdm', '>= 0.1.0', platforms: [:mswin, :mingw, :x64_mingw]

# --- 開発用 ---
group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'webrick' # ✅ Ruby 3系では必須（Webrickが標準でなくなったため）
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  gem 'webdrivers'
end

