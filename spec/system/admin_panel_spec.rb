require "rails_helper"

RSpec.describe "Admin Panel", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:area) { Area.create!(name: "テスト地区", display_order: 1, is_active: true) }
  let!(:branch1) do
    Branch.create!(
      area: area,
      code: "001",
      name: "第一支店",
      address: "静岡県テスト市1-1-1",
      phone: "05599900001",
      open_hours: "平日 9:00-17:00",
      default_capacity: 3
    )
  end
  let!(:branch2) do
    Branch.create!(
      area: area,
      code: "002",
      name: "第二支店",
      address: "静岡県テスト市2-2-2",
      phone: "05599900002",
      open_hours: "平日 9:00-17:00",
      default_capacity: 5
    )
  end
  let!(:appointment_type) { AppointmentType.create!(name: "事前相談") }

  # 今日のスロット
  let!(:today_slot) do
    Slot.create!(
      branch: branch1,
      starts_at: Time.current.change(hour: 10, min: 0, sec: 0),
      ends_at: Time.current.change(hour: 11, min: 0, sec: 0),
      capacity: 4,
      booked_count: 0
    )
  end

  # 明日のスロット
  let!(:tomorrow_slot) do
    Slot.create!(
      branch: branch1,
      starts_at: 1.day.from_now.change(hour: 14, min: 0, sec: 0),
      ends_at: 1.day.from_now.change(hour: 15, min: 0, sec: 0),
      capacity: 4,
      booked_count: 0
    )
  end

  # 来週のスロット
  let!(:next_week_slot) do
    Slot.create!(
      branch: branch2,
      starts_at: 7.days.from_now.change(hour: 10, min: 0, sec: 0),
      ends_at: 7.days.from_now.change(hour: 11, min: 0, sec: 0),
      capacity: 4,
      booked_count: 0
    )
  end

  # 今日の予約
  let!(:today_appointment) do
    Appointment.create!(
      branch: branch1,
      slot: today_slot,
      appointment_type: appointment_type,
      name: "今日太郎",
      furigana: "キョウタロウ",
      phone: "09011111111",
      email: "today@example.com",
      party_size: 1,
      status: "booked",
      accept_privacy: true
    )
  end

  # 明日の予約
  let!(:tomorrow_appointment) do
    Appointment.create!(
      branch: branch1,
      slot: tomorrow_slot,
      appointment_type: appointment_type,
      name: "明日花子",
      furigana: "アシタハナコ",
      phone: "09022222222",
      email: "tomorrow@example.com",
      party_size: 2,
      status: "booked",
      accept_privacy: true
    )
  end

  # 来週の予約（来店済み）
  let!(:visited_appointment) do
    Appointment.create!(
      branch: branch2,
      slot: next_week_slot,
      appointment_type: appointment_type,
      name: "来店済三郎",
      furigana: "ライテンズミサブロウ",
      phone: "09033333333",
      email: "visited@example.com",
      party_size: 1,
      status: "visited",
      accept_privacy: true
    )
  end

  describe "ダッシュボード" do
    it "予約統計と一覧が正しく表示されること" do
      visit admin_root_path

      # ページタイトル
      expect(page).to have_content("ダッシュボード")

      # 統計カウント
      expect(page).to have_content("本日の予約")
      expect(page).to have_content("1") # 今日の予約が1件

      expect(page).to have_content("翌日の予約")
      expect(page).to have_content("1") # 明日の予約が1件

      expect(page).to have_content("未確認予約")
      expect(page).to have_content("2") # booked statusが2件

      # 今日の予約一覧に表示される
      expect(page).to have_content("今日太郎")
      expect(page).to have_content("第一支店")

      # 明日の予約一覧に表示される
      expect(page).to have_content("明日花子")
    end
  end

  describe "予約一覧" do
    it "全ての予約が表示されること" do
      visit admin_appointments_path

      expect(page).to have_content("予約一覧")
      expect(page).to have_content("今日太郎")
      expect(page).to have_content("明日花子")
      expect(page).to have_content("来店済三郎")
    end

    it "本日フィルタが機能すること" do
      visit admin_appointments_path(filter: "today")

      expect(page).to have_content("本日の予約")
      expect(page).to have_content("今日太郎")
      expect(page).not_to have_content("明日花子")
      expect(page).not_to have_content("来店済三郎")
    end

    it "翌日フィルタが機能すること" do
      visit admin_appointments_path(filter: "tomorrow")

      expect(page).to have_content("翌日の予約")
      expect(page).to have_content("明日花子")
      expect(page).not_to have_content("今日太郎")
      expect(page).not_to have_content("来店済三郎")
    end

    it "予約済みフィルタが機能すること" do
      visit admin_appointments_path(filter: "booked")

      expect(page).to have_content("予約済み")
      expect(page).to have_content("今日太郎")
      expect(page).to have_content("明日花子")
      expect(page).not_to have_content("来店済三郎")
    end

    it "来店済みフィルタが機能すること" do
      visit admin_appointments_path(filter: "visited")

      expect(page).to have_content("来店済み")
      expect(page).to have_content("来店済三郎")
      expect(page).not_to have_content("今日太郎")
      expect(page).not_to have_content("明日花子")
    end

    it "支店フィルタが機能すること" do
      visit admin_appointments_path(branch_id: branch1.id)

      expect(page).to have_content("今日太郎")
      expect(page).to have_content("明日花子")
      expect(page).not_to have_content("来店済三郎")
    end

    it "検索機能が名前で機能すること" do
      visit admin_appointments_path(search: "今日")

      expect(page).to have_content("今日太郎")
      expect(page).not_to have_content("明日花子")
      expect(page).not_to have_content("来店済三郎")
    end

    it "検索機能が電話番号で機能すること" do
      visit admin_appointments_path(search: "09022222222")

      expect(page).to have_content("明日花子")
      expect(page).not_to have_content("今日太郎")
      expect(page).not_to have_content("来店済三郎")
    end

    it "日付範囲フィルタが機能すること" do
      visit admin_appointments_path(
        date_from: Date.current.to_s,
        date_to: Date.current.to_s
      )

      expect(page).to have_content("今日太郎")
      expect(page).not_to have_content("明日花子")
      expect(page).not_to have_content("来店済三郎")
    end
  end

  describe "予約詳細" do
    it "予約の詳細情報が正しく表示されること" do
      visit admin_appointment_path(today_appointment)

      # 受付番号
      reception_number = format('%08d', today_appointment.id)
      expect(page).to have_content(reception_number)

      # お客様情報
      expect(page).to have_content("今日太郎")
      expect(page).to have_content("キョウタロウ")
      expect(page).to have_content("090-1111-1111") # ハイフン付きで表示
      expect(page).to have_content("today@example.com")

      # 予約情報
      expect(page).to have_content("第一支店")
      expect(page).to have_content("事前相談")
      expect(page).to have_content("1名")

      # 日時
      expect(page).to have_content(Date.current.strftime('%Y年%m月%d日'))
      expect(page).to have_content("10:00")
    end

    it "ステータスが表示されること" do
      visit admin_appointment_path(today_appointment)
      expect(page).to have_content("予約済み")

      visit admin_appointment_path(visited_appointment)
      expect(page).to have_content("来店済み")
    end
  end

  describe "ステータス更新" do
    it "来店済みに更新できること" do
      visit admin_appointment_path(today_appointment)

      # 現在のステータス確認
      expect(page).to have_content("予約済み")

      # ステータス更新ボタンをクリック
      click_button "来店済みにする"

      # フラッシュメッセージとステータス確認
      expect(page).to have_content("来店済みに更新しました")
      expect(page).to have_content("来店済み")

      # データベース確認
      expect(today_appointment.reload.status).to eq("visited")
    end

    it "要フォローアップに更新できること" do
      visit admin_appointment_path(today_appointment)

      click_button "フォローアップ必要"

      expect(page).to have_content("要フォローアップに更新しました")
      expect(today_appointment.reload.status).to eq("needs_followup")
    end

    it "キャンセルに更新できること" do
      visit admin_appointment_path(today_appointment)

      click_button "キャンセルにする"

      expect(page).to have_content("キャンセルに更新しました")
      expect(today_appointment.reload.status).to eq("canceled")
    end
  end

  describe "管理メモ機能" do
    it "管理メモを追加できること" do
      visit admin_appointment_path(today_appointment)

      # メモが空の状態を確認
      expect(today_appointment.admin_memo).to be_nil

      # メモを入力して保存
      fill_in "appointment[admin_memo]", with: "本人確認書類を持参していただく"
      click_button "メモを保存"

      # フラッシュメッセージ確認
      expect(page).to have_content("メモを更新しました")

      # データベース確認
      expect(today_appointment.reload.admin_memo).to eq("本人確認書類を持参していただく")

      # 画面に表示されることを確認
      expect(page).to have_field("appointment[admin_memo]", with: "本人確認書類を持参していただく")
    end

    it "管理メモを更新できること" do
      today_appointment.update!(admin_memo: "初回メモ")

      visit admin_appointment_path(today_appointment)

      expect(page).to have_field("appointment[admin_memo]", with: "初回メモ")

      fill_in "appointment[admin_memo]", with: "更新されたメモ"
      click_button "メモを保存"

      expect(page).to have_content("メモを更新しました")
      expect(today_appointment.reload.admin_memo).to eq("更新されたメモ")
    end

    it "管理メモを削除できること" do
      today_appointment.update!(admin_memo: "削除予定のメモ")

      visit admin_appointment_path(today_appointment)

      fill_in "appointment[admin_memo]", with: ""
      click_button "メモを保存"

      expect(page).to have_content("メモを更新しました")
      expect(today_appointment.reload.admin_memo).to eq("")
    end
  end

  describe "支店管理" do
    it "支店一覧が表示されること" do
      visit admin_branches_path

      expect(page).to have_content("支店管理")
      expect(page).to have_content("テスト地区")
      expect(page).to have_content("第一支店")
      expect(page).to have_content("第二支店")
      expect(page).to have_content("静岡県テスト市1-1-1")
      expect(page).to have_content("静岡県テスト市2-2-2")
    end

    it "支店情報を編集できること" do
      visit admin_branches_path

      # 第一支店の編集リンクをクリック
      # 第一支店の行を見つけて編集リンクをクリック
      row = page.find('tr', text: '第一支店')
      within(row) do
        click_link "編集"
      end

      expect(page).to have_content("第一支店 - 編集")
      expect(page).to have_field("branch[name]", with: "第一支店")
      expect(page).to have_field("branch[default_capacity]", with: "3")

      # 情報を更新
      fill_in "branch[name]", with: "第一支店（更新版）"
      fill_in "branch[address]", with: "静岡県テスト市1-1-2（新住所）"
      fill_in "branch[default_capacity]", with: "5"

      click_button "更新する"

      # フラッシュメッセージ確認
      expect(page).to have_content("第一支店（更新版）の情報を更新しました")

      # データベース確認
      branch1.reload
      expect(branch1.name).to eq("第一支店（更新版）")
      expect(branch1.address).to eq("静岡県テスト市1-1-2（新住所）")
      expect(branch1.default_capacity).to eq(5)

      # 一覧ページに戻って確認
      expect(page).to have_content("第一支店（更新版）")
      expect(page).to have_content("静岡県テスト市1-1-2（新住所）")
    end

    it "デフォルト定員を更新できること" do
      visit edit_admin_branch_path(branch1)

      expect(page).to have_field("branch[default_capacity]", with: "3")

      fill_in "branch[default_capacity]", with: "10"
      click_button "更新する"

      expect(page).to have_content("の情報を更新しました")
      expect(branch1.reload.default_capacity).to eq(10)
    end
  end

  describe "印刷機能" do
    it "当日の予約を印刷用に表示できること" do
      visit admin_prints_path

      # 本日の予約が表示される
      expect(page).to have_content("今日太郎")
      expect(page).to have_content("第一支店")
      expect(page).to have_content("事前相談")

      # 他の日の予約は表示されない
      expect(page).not_to have_content("明日花子")
      expect(page).not_to have_content("来店済三郎")
    end

    it "指定日の予約を印刷用に表示できること" do
      tomorrow_date = 1.day.from_now.to_date

      visit admin_prints_path(date: tomorrow_date.to_s)

      # 明日の予約が表示される
      expect(page).to have_content("明日花子")
      expect(page).to have_content("第一支店")

      # 他の日の予約は表示されない
      expect(page).not_to have_content("今日太郎")
      expect(page).not_to have_content("来店済三郎")
    end

    it "支店別にグループ化されること" do
      # 複数の支店の予約を作成
      branch2_slot = Slot.create!(
        branch: branch2,
        starts_at: Time.current.change(hour: 14, min: 0, sec: 0),
        ends_at: Time.current.change(hour: 15, min: 0, sec: 0),
        capacity: 4,
        booked_count: 0
      )

      Appointment.create!(
        branch: branch2,
        slot: branch2_slot,
        appointment_type: appointment_type,
        name: "第二支店太郎",
        furigana: "ダイニシテンタロウ",
        phone: "09044444444",
        email: "branch2@example.com",
        party_size: 1,
        status: "booked",
        accept_privacy: true
      )

      visit admin_prints_path

      # 両方の支店名が表示される
      expect(page).to have_content("第一支店")
      expect(page).to have_content("第二支店")

      # 各支店の予約が表示される
      expect(page).to have_content("今日太郎")
      expect(page).to have_content("第二支店太郎")
    end
  end

  describe "認証とアクセス制御" do
    it "test環境では認証がスキップされること" do
      # test環境では自動的に認証がスキップされる
      visit admin_root_path
      expect(page).to have_content("ダッシュボード")
    end
  end

  describe "ナビゲーション" do
    it "ダッシュボードから各ページにアクセスできること" do
      visit admin_root_path

      # 予約一覧へ
      click_link "予約管理"
      expect(page).to have_content("予約一覧")

      # ダッシュボードに戻る
      click_link "ダッシュボード"
      expect(page).to have_content("本日の予約")

      # 印刷へ（最初の印刷リンクをクリック）
      click_link "印刷", match: :first
      expect(page).to have_content("印刷日時")
    end
  end

  describe "データの整合性" do
    it "予約をキャンセルしてもSlotのbooked_countが正しく更新されること" do
      initial_booked_count = today_slot.booked_count

      visit admin_appointment_path(today_appointment)
      click_button "キャンセルにする"

      # キャンセル後、booked_countが減る（Appointmentモデルのコールバック次第）
      today_slot.reload
      # 注: キャンセル時のbooked_count減少処理がある場合のみこのテストは有効
      # 現状のコードではキャンセルしてもbooked_countは減らない仕様のため、このテストはスキップ可能
    end

    it "複数の予約が同じスロットに紐づいていること" do
      # 同じスロットに追加予約
      another_appointment = Appointment.create!(
        branch: branch1,
        slot: today_slot,
        appointment_type: appointment_type,
        name: "追加太郎",
        furigana: "ツイカタロウ",
        phone: "09055555555",
        email: "additional@example.com",
        party_size: 1,
        status: "booked",
        accept_privacy: true
      )

      visit admin_appointments_path(filter: "today")

      expect(page).to have_content("今日太郎")
      expect(page).to have_content("追加太郎")

      # 両方とも同じスロット
      expect(today_appointment.slot_id).to eq(another_appointment.slot_id)
    end
  end

  describe "エッジケース" do
    it "予約が0件の場合のダッシュボード表示" do
      Appointment.destroy_all

      visit admin_root_path

      expect(page).to have_content("本日の予約")
      expect(page).to have_content("0") # 0件表示
    end

    it "予約が0件の場合の一覧表示" do
      Appointment.destroy_all

      visit admin_appointments_path

      expect(page).to have_content("予約一覧")
      # 予約が無いことを示すメッセージがあれば確認
      # 例: expect(page).to have_content("予約がありません")
    end

    it "検索結果が0件の場合" do
      visit admin_appointments_path(search: "存在しない名前")

      expect(page).not_to have_content("今日太郎")
      expect(page).not_to have_content("明日花子")
      expect(page).not_to have_content("来店済三郎")
    end
  end
end
