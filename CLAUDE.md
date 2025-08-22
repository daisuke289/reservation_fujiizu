# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

富士伊豆農業協同組合の相続相談予約システム。高齢者向けの来店予約WebアプリケーションとバックオフィスでのA4印刷管理機能を提供。

- **Tech Stack**: Rails 8.0, PostgreSQL, Tailwind CSS, GoodJob
- **Target Users**: 高齢者、遺族、農協組合員
- **Current Status**: 完全実装済み（利用者画面、管理画面、メール送信、テスト）

## Development Commands

```bash
# Setup
bundle install
bin/rails db:drop db:create db:migrate db:seed

# Development server with background jobs
bin/dev

# Testing
RAILS_ENV=test bin/rails db:drop db:create db:migrate
bundle exec rspec spec/models/appointment_spec.rb spec/system/reservations_smoke_spec.rb
bundle exec rspec spec/system/reservations_full_flow_spec.rb
bundle exec rspec

# Single test file
bundle exec rspec spec/models/appointment_spec.rb
```

## Architecture Overview

### Data Model Hierarchy
```
Area (8 regions) → Branch (2 per area) → Slot (30min intervals) → Appointment
                                      ↗ AppointmentType (6 consultation types)
```

### Controller Structure
- **Public Flow**: `Public::HomeController` → `Reserve::StepsController` → `Reserve::ConfirmController` → `Reserve::CompleteController`
- **Admin Flow**: Basic auth → `Admin::DashboardController` → `Admin::AppointmentsController` → `Admin::PrintsController`

### Service Layer
- **AppointmentService**: Handles transaction safety, slot capacity checks, duplicate prevention with optimistic locking
- **AppointmentMailer**: Sends confirmation emails with specific inheritance consultation details

### Session-based Wizard Flow
Multi-step reservation uses `session[:reservation_data]` to persist state across:
1. Area/Branch selection  
2. Date/Time slot selection
3. Customer information input
4. Confirmation screen
5. Transaction completion with email

### Key Validations
- Phone: 10-11 digits only, no hyphens
- Same-day duplicate prevention by phone number  
- Furigana: Full-width Katakana validation
- Slot capacity with race condition protection

## Admin Features

- **Dashboard**: Today/tomorrow statistics with quick actions
- **Appointment Management**: Filter/search with status updates (visited, follow-up, canceled)
- **Print System**: A4 layouts grouped by branch for daily operations
- **Basic Auth**: admin/password (configurable in ApplicationController)

## Email System
- **GoodJob**: Background job processing
- **Templates**: Inheritance consultation specific with required documents list
- **Localization**: Japanese date/time formatting via `config/locales/ja.yml`

## Testing Strategy
- **Smoke Tests**: Basic page access and button presence
- **Model Tests**: Validation coverage including phone format and duplicate prevention  
- **System Tests**: Full E2E flow with rescue-based UI text flexibility
- **Test DB**: Separate test environment with full reset capability
