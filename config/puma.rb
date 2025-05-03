# Puma can serve each request in a thread from an internal thread pool.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Worker timeout in development
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# ✅ RailwayやDockerで使う TCPバインド方式（これだけでOK）
bind "tcp://0.0.0.0:#{ENV.fetch("PORT", 8080)}"

# The environment Puma will run in
environment ENV.fetch("RAILS_ENV", "production")

# PID file location
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

# Allow puma to be restarted by `rails restart` command
plugin :tmp_restart

