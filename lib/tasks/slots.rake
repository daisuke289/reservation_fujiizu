namespace :slots do
  desc "Generate initial slot data for 3 months (current + next 2 months)"
  task generate_initial: :environment do
    puts "Generating slots for 3 months..."

    today = Date.today
    total_slots = 0

    # 今月
    count = SlotGeneratorService.generate_for_month(today.year, today.month)
    puts "✓ Generated #{count} slots for #{today.strftime('%Y年%m月')}"
    total_slots += count

    # 翌月
    next_month = today.next_month
    count = SlotGeneratorService.generate_for_month(next_month.year, next_month.month)
    puts "✓ Generated #{count} slots for #{next_month.strftime('%Y年%m月')}"
    total_slots += count

    # 翌々月
    month_after_next = today.next_month.next_month
    count = SlotGeneratorService.generate_for_month(month_after_next.year, month_after_next.month)
    puts "✓ Generated #{count} slots for #{month_after_next.strftime('%Y年%m月')}"
    total_slots += count

    puts "\nDone! Total slots: #{total_slots}"
    puts "Database total: #{Slot.count}"
  end

  desc "Generate slots for a specific month (YEAR=2025 MONTH=3)"
  task generate_month: :environment do
    year = ENV["YEAR"]&.to_i || Date.today.year
    month = ENV["MONTH"]&.to_i || Date.today.month

    count = SlotGeneratorService.generate_for_month(year, month)
    puts "Generated #{count} slots for #{year}年#{month}月"
  end

  desc "Clear all future slots (use with caution)"
  task clear_future: :environment do
    count = Slot.where("starts_at > ?", Time.current).delete_all
    puts "Deleted #{count} future slots"
  end
end
