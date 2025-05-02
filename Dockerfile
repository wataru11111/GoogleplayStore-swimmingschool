# Entrypoint追加（server.pid問題回避）
COPY bin/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Puma起動コマンド（このCMDは元からあればそのまま）
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
