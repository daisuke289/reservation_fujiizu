#!/bin/bash

# Codespace初回セットアップスクリプト
echo "🚀 Starting Codespace setup..."

# 1. Bundle install
echo "📦 Installing Ruby gems..."
bundle install

# 2. Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL..."
until docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done
echo "✅ PostgreSQL is ready!"

# 3. Database setup
echo "🗄️  Setting up database..."
if bundle exec rails db:exists 2>/dev/null; then
  echo "Database already exists, running migrations..."
  bundle exec rails db:migrate
else
  echo "Creating database..."
  bundle exec rails db:create db:migrate db:seed

  # Phase 2完了後: Slot初期データ生成
  if bundle exec rails runner "puts defined?(SlotGeneratorService) ? 'exists' : 'not_found'" | grep -q "exists"; then
    echo "📅 Generating initial slot data..."
    bundle exec rails slots:generate_initial
  fi
fi

# 4. Verify setup
echo "🔍 Verifying setup..."
bundle exec rails db:migrate:status

echo "✅ Codespace setup complete!"
echo ""
echo "🎉 You can now run:"
echo "  - bin/dev          # Start Rails server with GoodJob"
echo "  - bin/rails c      # Open Rails console"
echo "  - bundle exec rspec # Run tests"
echo ""
