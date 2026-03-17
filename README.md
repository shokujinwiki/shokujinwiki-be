# shokujinwiki-be

## 環境

- Ruby 3.4.8
- PostgreSQL 17
- Bundler

## セットアップ

```bash
bundle install
docker compose up -d
bin/rails db:create db:migrate
bin/rails server
```

## テスト・Lint

```bash
bundle exec rspec       # テスト
bin/rubocop             # Lint
bin/ci                  # 全チェック (brakeman, bundler-audit, rubocop, rspec)
```

## デプロイ

Kamal + Docker。`main` ブランチへの push で GitHub Actions 経由で自動デプロイ。
