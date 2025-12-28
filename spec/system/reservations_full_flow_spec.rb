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

    # カレンダーページ
    visit reserve_steps_calendar_path(branch_id: branch.id)
    expect(page).to have_content("予約カレンダー")
    expect(page).to have_css("table") # Calendar is displayed as a table
    expect(page).to have_content("月") # Weekday headers

    # 時間選択ページ（未来の日付でアクセス）
    future_date = 1.day.from_now.to_date
    visit reserve_steps_time_selection_path(branch_id: branch.id, date: future_date.to_s)
    expect(page).to have_content("ご希望の時間を選択してください")
    expect(page).to have_content(future_date.strftime('%Y年%m月%d日'))

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

  it "予約フローを完了し、予約確定後の動作を確認する" do
    # テストデータ作成
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
    # 7日後の平日を選択（営業日になるように）
    slot_date = 7.days.from_now.change(hour: 10, min: 0)
    # 土日祝を避けるため、平日になるまで日付を進める
    while slot_date.wday == 0 || slot_date.wday == 6 # 0=日曜、6=土曜
      slot_date += 1.day
    end

    slot = Slot.create!(
      branch: branch,
      starts_at: slot_date,
      ends_at: slot_date + 1.hour,
      capacity: 4,
      booked_count: 0
    )
    appointment_type = AppointmentType.create!(name: "事前相談")

    # 予約前のAppointment数とSlotのbooked_countを記録
    initial_appointment_count = Appointment.count
    initial_booked_count = slot.booked_count

    # エリア選択から開始
    visit reserve_steps_area_path
    expect(page).to have_content("エリアを選択してください")
    expect(page).to have_content("テスト地区")

    # エリアボタンをクリック（ボタン内にテキストが含まれているので全体をクリック）
    find("button", text: /テスト地区/).click

    # 支店選択
    expect(page).to have_content("支店を選択してください")
    expect(page).to have_content("テスト支店")
    click_link "この支店で予約する"

    # カレンダーで日付選択
    expect(page).to have_content("予約カレンダー")
    future_date = slot_date.to_date

    # 次月のカレンダーに移動する必要がある場合
    current_month = Date.today.beginning_of_month
    if future_date.beginning_of_month > current_month
      # 次月ボタンをクリック
      find("a", text: /#{future_date.strftime('%Y年%-m月')}/).click
      expect(page).to have_content(future_date.strftime('%Y年%-m月'))
    end

    # 日付のリンクをクリック（URLにdate=YYY-MM-DDが含まれるリンクを探す）
    find("a[href*='date=#{future_date}']").click

    # 時間選択
    expect(page).to have_content("ご希望の時間を選択してください")
    click_link slot_date.strftime('%H:%M')

    # お客様情報入力ページ
    expect(page).to have_content("お客様情報をご入力ください")

    # フォーム入力
    fill_in "appointment[name]", with: "山田太郎"
    fill_in "appointment[furigana]", with: "ヤマダタロウ"
    fill_in "appointment[phone]", with: "09012345678"
    fill_in "appointment[email]", with: "test@example.com"
    select "事前相談", from: "appointment[appointment_type_id]"
    select "1", from: "appointment[party_size]"
    check "appointment[accept_privacy]"

    # 確認画面へ
    click_button "入力内容を確認する"

    # 確認画面の表示確認
    expect(page).to have_content("ご予約内容をご確認ください")
    expect(page).to have_content("山田太郎")
    expect(page).to have_content("ヤマダタロウ")
    expect(page).to have_content("090-1234-5678")
    expect(page).to have_content("test@example.com")
    expect(page).to have_content("事前相談")
    expect(page).to have_content("1名")

    # 予約確定ボタンをクリック
    click_button "予約を確定する"

    # 完了画面の表示確認
    expect(page).to have_content("ご予約が完了しました")
    expect(page).to have_content("山田太郎")

    # データベースに予約が登録されていることを確認
    expect(Appointment.count).to eq(initial_appointment_count + 1)

    # 作成されたAppointmentの内容確認
    appointment = Appointment.last
    expect(appointment.name).to eq("山田太郎")
    expect(appointment.furigana).to eq("ヤマダタロウ")
    expect(appointment.phone).to eq("09012345678")
    expect(appointment.email).to eq("test@example.com")
    expect(appointment.appointment_type_id).to eq(appointment_type.id)
    expect(appointment.party_size).to eq(1)
    expect(appointment.slot_id).to eq(slot.id)
    expect(appointment.status).to eq("booked")

    # Slotのbooked_countが増えていることを確認
    slot.reload
    expect(slot.booked_count).to eq(initial_booked_count + 1)
  end
end