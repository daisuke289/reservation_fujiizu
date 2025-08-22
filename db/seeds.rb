# Seeds for Fuji-Izu Agricultural Cooperative Reservation System
# This creates initial data for testing and demonstration purposes

# Clear existing data
puts "Cleaning up existing data..."
Appointment.destroy_all
Slot.destroy_all
AppointmentType.destroy_all
Branch.destroy_all
Area.destroy_all

# Create Areas
puts "Creating areas..."
areas = [
  { name: "富士宮地区", sort_order: 1 },
  { name: "富士地区", sort_order: 2 },
  { name: "沼津地区", sort_order: 3 },
  { name: "三島地区", sort_order: 4 },
  { name: "御殿場地区", sort_order: 5 },
  { name: "裾野地区", sort_order: 6 },
  { name: "伊豆地区", sort_order: 7 },
  { name: "東伊豆地区", sort_order: 8 }
]

areas.each do |area_data|
  Area.create!(area_data)
end

# Create Branches (2 per area)
puts "Creating branches..."
Area.all.each do |area|
  2.times do |i|
    branch_name = case area.name
                  when "富士宮地区"
                    i == 0 ? "富士宮支店" : "富士宮西支店"
                  when "富士地区"
                    i == 0 ? "富士支店" : "富士南支店"
                  when "沼津地区"
                    i == 0 ? "沼津支店" : "沼津西支店"
                  when "三島地区"
                    i == 0 ? "三島支店" : "三島北支店"
                  when "御殿場地区"
                    i == 0 ? "御殿場支店" : "御殿場東支店"
                  when "裾野地区"
                    i == 0 ? "裾野支店" : "裾野西支店"
                  when "伊豆地区"
                    i == 0 ? "伊豆支店" : "伊豆中央支店"
                  when "東伊豆地区"
                    i == 0 ? "東伊豆支店" : "熱海支店"
                  end

    Branch.create!(
      area: area,
      name: branch_name,
      sort_order: i + 1
    )
  end
end

# Create Appointment Types
puts "Creating appointment types..."
appointment_types = [
  { name: "住宅ローン相談", sort_order: 1 },
  { name: "資産運用相談", sort_order: 2 },
  { name: "保険相談", sort_order: 3 },
  { name: "農業融資相談", sort_order: 4 },
  { name: "カードローン相談", sort_order: 5 },
  { name: "その他金融相談", sort_order: 6 }
]

appointment_types.each do |type_data|
  AppointmentType.create!(type_data)
end

# Create Slots for today and tomorrow (9:00-16:30, 30-minute intervals)
puts "Creating time slots..."

[Date.current, Date.current + 1.day].each do |date|
  Branch.all.each do |branch|
    # 9:00-16:30 with 30-minute intervals
    start_time = date.beginning_of_day + 9.hours
    end_time = date.beginning_of_day + 16.hours + 30.minutes

    current_time = start_time
    while current_time < end_time
      slot_end = current_time + 30.minutes
      
      Slot.create!(
        branch: branch,
        starts_at: current_time,
        ends_at: slot_end,
        capacity: 4,
        status: 'available'
      )
      
      current_time = slot_end
    end
  end
end

# Create some sample appointments
puts "Creating sample appointments..."

# Get some random slots
available_slots = Slot.where(status: 'available').limit(20)

sample_customers = [
  { name: "田中 太郎", furigana: "タナカ タロウ", phone: "08012345678", email: "tanaka@example.com" },
  { name: "佐藤 花子", furigana: "サトウ ハナコ", phone: "09087654321", email: "sato@example.com" },
  { name: "鈴木 一郎", furigana: "スズキ イチロウ", phone: "08011111111", email: nil },
  { name: "高橋 美香", furigana: "タカハシ ミカ", phone: "09022222222", email: "takahashi@example.com" },
  { name: "山田 次郎", furigana: "ヤマダ ジロウ", phone: "08033333333", email: nil }
]

available_slots.first(5).each_with_index do |slot, index|
  customer = sample_customers[index]
  
  appointment = Appointment.create!(
    slot: slot,
    appointment_type: AppointmentType.all.sample,
    name: customer[:name],
    furigana: customer[:furigana],
    phone: customer[:phone],
    email: customer[:email],
    party_size: rand(1..4),
    purpose: "#{AppointmentType.all.sample.name}について詳しく相談したいです。",
    notes: index.even? ? "平日の夕方以降でお願いします。" : nil,
    status: ['booked', 'visited', 'needs_followup'].sample
  )
  
  # Add admin memo to some appointments
  if index.odd?
    appointment.update!(admin_memo: "#{Date.current.strftime('%m/%d')} 電話でフォローアップ済み")
  end
end

# Update slot statuses
Slot.joins(:appointments).update_all(status: 'booked')

puts "Seed data created successfully!"
puts "Areas: #{Area.count}"
puts "Branches: #{Branch.count}"
puts "Appointment Types: #{AppointmentType.count}"
puts "Slots: #{Slot.count}"
puts "Sample Appointments: #{Appointment.count}"
