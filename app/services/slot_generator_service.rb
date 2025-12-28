class SlotGeneratorService
  TIME_SLOTS = [
    ["09:00", "10:00"],
    ["10:00", "11:00"],
    ["11:00", "12:00"],
    ["12:00", "13:00"],
    ["13:00", "14:00"],
    ["14:00", "15:00"]
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

  # 年末年始判定
  def self.year_end_new_year?(date)
    # 12/30, 12/31, 1/1, 1/2, 1/3
    (date.month == 12 && date.day >= 30) ||
      (date.month == 1 && date.day <= 3)
  end

  # 営業日判定
  def self.business_day?(date)
    return false if date.saturday?
    return false if date.sunday?
    return false if HolidayJp.holiday?(date)
    return false if year_end_new_year?(date)
    true
  end
end
