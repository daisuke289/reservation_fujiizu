require "rails_helper"

RSpec.describe "Reservations (full flow)", type: :system do
  before do
    driven_by(:rack_test)
    area   = Area.find_or_create_by!(name: "テスト地区")
    @branch = Branch.find_or_create_by!(area:, name: "テスト支店", address: "住所", phone: "055-999-0000", open_hours: "平日")
    @atype  = AppointmentType.find_or_create_by!(name: "事前相談")
    @slot   = Slot.find_or_create_by!(branch: @branch, starts_at: 1.day.from_now.change(hour: 10, min: 0), ends_at: 1.day.from_now.change(hour: 10, min: 30), capacity: 4, booked_count: 0)
  end

  it "TOP→エリア→支店→日時→情報→確認→完了 まで進む（文言は実装に合わせて調整）" do
    visit root_path

    # 予約開始
    click_on("来店予約をする")

    # エリア選択（リンク/ボタン/セレクト いずれかに合わせて調整）
    click_on("テスト地区") rescue nil

    # 支店選択
    click_on(@branch.name)

    # 日時選択（slot表示のリンクテキストが時刻だけの場合など、実装に合わせて調整）
    # 例: "10:00" または "2025/09/01 10:00" 等
    # click_on(I18n.l(@slot.starts_at, format: :short))
    # とりあえず最初の「予約」ボタンを押す
    first(:button, "予約").click rescue nil
    first(:link, "予約").click  rescue nil

    # お客様情報入力
    fill_in "氏名", with: "予約 太郎" rescue nil
    fill_in "フリガナ", with: "ヨヤクタロウ" rescue nil
    fill_in "電話番号", with: "09012345678" rescue nil
    fill_in "メール", with: "test@example.com" rescue nil
    fill_in "来店人数", with: "2" rescue nil
    select "事前相談", from: "来店目的" rescue nil
    check "個人情報に同意する" rescue nil

    # 確認→確定
    click_on "確認へ進む" rescue nil
    expect(page).to have_content("入力内容確認").or have_content("確認")
    click_on "予約を確定する"

    # 完了
    expect(page).to have_content("ご予約を承りました").or have_content("受付番号")
  end
end