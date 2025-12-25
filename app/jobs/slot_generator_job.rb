class SlotGeneratorJob < ApplicationJob
  queue_as :default

  def perform
    # 翌々月分のSlotを生成
    target_date = 2.months.from_now

    Rails.logger.info "SlotGeneratorJob started for #{target_date.strftime('%Y年%m月')}"

    slot_count = SlotGeneratorService.generate_for_month(
      target_date.year,
      target_date.month
    )

    Rails.logger.info "SlotGeneratorJob completed: #{slot_count} slots created"
  rescue StandardError => e
    Rails.logger.error "SlotGeneratorJob failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end
