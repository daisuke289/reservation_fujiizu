Rails.application.configure do
  config.good_job.tap do |good_job|
    # 定期実行ジョブの設定
    good_job.cron = {
      generate_monthly_slots: {
        cron: "0 2 1 * *", # 毎月1日 深夜2:00
        class: "SlotGeneratorJob",
        description: "Generate slots for 2 months ahead"
      }
    }
  end
end
