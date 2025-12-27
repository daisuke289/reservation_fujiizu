require "rails_helper"

RSpec.describe "Reservations (full flow)", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "TOP→予約ページ アクセス可能であること" do
    visit root_path
    expect(page).to have_content("富士伊豆農業協同組合")

    # 予約開始ボタンの存在確認（reserve_steps_pathからreserve_steps_area_pathへリダイレクト）
    expect(page).to have_link("今すぐ予約する", href: reserve_steps_path)

    # エリア選択ページにアクセス
    visit reserve_steps_area_path
    expect(page).to have_content("エリアを選択してください")
  end

  it "各予約ステップのページが正常に表示されること" do
    area = Area.create!(name: "テスト地区", display_order: 1, is_active: true)
    branch = Branch.create!(
      area: area,
      code: "001",
      name: "テスト支店",
      address: "静岡県テスト市テスト町1-2-3",
      phone: "05599900000",
      open_hours: "平日 9:00-17:00",
      default_capacity: 1
    )
    slot = Slot.create!(
      branch: branch,
      starts_at: 1.day.from_now.change(hour: 10, min: 0),
      ends_at: 1.day.from_now.change(hour: 10, min: 30),
      capacity: 4,
      booked_count: 0
    )
    appointment_type = AppointmentType.create!(name: "事前相談")

    # エリア選択ページ
    visit reserve_steps_area_path
    expect(page).to have_content("エリアを選択してください")
    expect(page).to have_content("テスト地区")

    # 支店選択ページ（パラメータ付き）
    visit reserve_steps_branch_path(area_id: area.id)
    expect(page).to have_content("支店を選択してください")
    expect(page).to have_content("テスト支店")

    # 日時選択ページ（パラメータ付き）
    visit reserve_steps_datetime_path(branch_id: branch.id)
    expect(page).to have_content("ご希望の日時を選択してください")

    # お客様情報入力ページ（パラメータ付き）
    visit reserve_steps_customer_path(slot_id: slot.id)
    expect(page).to have_content("お客様情報をご入力ください")
    expect(page).to have_field("お名前")
    expect(page).to have_field("フリガナ")
    expect(page).to have_field("電話番号")
    expect(page).to have_field("メールアドレス")
    expect(page).to have_select("相談種別")
    expect(page).to have_select("ご来店人数")
    expect(page).to have_field("個人情報の取り扱いに同意します")
  end
end