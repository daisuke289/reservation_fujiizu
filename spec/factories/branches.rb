FactoryBot.define do
  factory :branch do
    association :area
    sequence(:code) { |n| sprintf('%03d', n) }
    name { "テスト支店" }
    address { "静岡県テスト市1-2-3" }
    phone { "0551234567" }
    open_hours { "平日 9:00-16:30" }
    default_capacity { 1 }
  end
end
