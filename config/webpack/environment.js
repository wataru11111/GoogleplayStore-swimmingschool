const { environment } = require('@rails/webpacker')

// ↓ 不要な node 設定を削除または修正
environment.config.set('node', false);

module.exports = environment
