FactoryBot.define do
  factory :area do
    sequence(:name) { |n| "テストエリア#{n}" }
    sequence(:display_order) { |n| n }
    jurisdiction { "テスト市、テスト町" }
    is_active { true }

    trait :inactive do
      is_active { false }
    end

    trait :without_jurisdiction do
      jurisdiction { nil }
    end
  end
end
