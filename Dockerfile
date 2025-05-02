# ベースイメージ（必要に応じて調整）
FROM ruby:3.3.0

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y nodejs npm build-essential libpq-dev default-mysql-client

# 作業ディレクトリを作成
WORKDIR /app

# GemfileとGemfile.lockをコピーしてbundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install

# アプリケーションコードをコピー
COPY . .

# ポートを開放（Railwayが使用するポート）
EXPOSE 8080

# server.pid を削除してからPumaを起動（ENTRYPOINTの代替）
CMD rm -f /app/tmp/pids/server.pid && bundle exec puma -C config/puma.rb

