require "rails_helper"

RSpec.describe "Reservations (smoke)", type: :system do
  it "トップにアクセスでき、予約開始ボタンがあること" do
    visit root_path
    expect(page).to have_content("相続相談")
    expect(page).to have_link("今すぐ予約する").or have_link("予約を開始する")
  end
end