require 'rails_helper'

RSpec.describe "Reserve::Steps", type: :request do
  let(:area) { create(:area) }
  let(:branch) { create(:branch, area: area) }

  describe "GET /reserve/steps/calendar" do
    it "カレンダー画面が表示される" do
      get reserve_steps_calendar_path(branch_id: branch.id)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('ご希望の日付を選択してください')
    end

    it "支店IDがない場合はリダイレクトされる" do
      get reserve_steps_calendar_path
      expect(response).to redirect_to(reserve_steps_area_path)
    end
  end

  describe "GET /reserve/steps/time_selection" do
    let(:date) { 1.day.from_now.to_date }

    it "時間選択画面が表示される" do
      # Create a slot for the test date
      Slot.create!(
        branch: branch,
        starts_at: date.to_time.change(hour: 10),
        ends_at: date.to_time.change(hour: 11),
        capacity: 1,
        booked_count: 0
      )

      get reserve_steps_time_selection_path(branch_id: branch.id, date: date.to_s)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('ご希望の時間を選択してください')
    end

    it "日付がない場合はカレンダーにリダイレクトされる" do
      get reserve_steps_time_selection_path(branch_id: branch.id)
      expect(response).to redirect_to(reserve_steps_calendar_path(branch_id: branch.id))
    end

    it "過去の日付の場合はカレンダーにリダイレクトされる" do
      past_date = 1.day.ago.to_date
      get reserve_steps_time_selection_path(branch_id: branch.id, date: past_date.to_s)
      expect(response).to redirect_to(reserve_steps_calendar_path(branch_id: branch.id))
    end
  end
end
