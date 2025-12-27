class SlotGeneratorService
  TIME_SLOTS = [
    ["09:00", "09:30"], ["09:30", "10:00"], ["10:00", "10:30"],
    ["10:30", "11:00"], ["11:00", "11:30"], ["11:30", "12:00"],
    # 昼休み 12:00-13:00 は除外
    ["13:00", "13:30"], ["13:30", "14:00"], ["14:00", "14:30"],
    ["14:30", "15:00"], ["15:00", "15:30"], ["15:30", "16:00"],
    ["16:00", "16:30"]
  ].freeze

  # 指定月の全営業日に対してSlot生成
  def self.generate_for_month(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    Rails.logger.info "Generating slots for #{year}年#{month}月"

    slot_count = 0
    (start_date..end_date).each do |date|
      next unless business_day?(date)

      Branch.find_each do |branch|
        slot_count += generate_slots_for_branch(branch, date)
      end
    end

    Rails.logger.info "Generated #{slot_count} slots for #{year}年#{month}月"
    slot_count
  end

  # 特定の支店・日付に対してSlot生成
  def self.generate_slots_for_branch(branch, date)
    created_count = 0

    TIME_SLOTS.each do |start_time, end_time|
      starts_at = Time.zone.parse("#{date} #{start_time}")
      ends_at = Time.zone.parse("#{date} #{end_time}")

      # 既に存在する場合はスキップ
      next if Slot.exists?(branch_id: branch.id, starts_at: starts_at)

      Slot.create!(
        branch: branch,
        starts_at: starts_at,
        ends_at: ends_at,
        capacity: branch.default_capacity,
        booked_count: 0
      )
      created_count += 1
    end

    created_count
  end

  # 営業日判定
  def self.business_day?(date)
    return false if date.saturday?
    return false if date.sunday?
    return false if HolidayJp.holiday?(date)
    true
  end
end
