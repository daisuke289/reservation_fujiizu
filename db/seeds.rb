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
  "Area A",
  "Area B",
  "Area C",
  "Area D",
  "Area E",
  "Area F",
  "Area G",
  "Area H"
]

areas.each do |area_name|
  Area.create!(name: area_name)
end

# Create Branches (2 per area)
puts "Creating branches..."
Area.all.each do |area|
  2.times do |i|
    branch_name = case area.name
                  when "Area A"
                    i == 0 ? "Branch A-1" : "Branch A-2"
                  when "Area B"
                    i == 0 ? "Branch B-1" : "Branch B-2"
                  when "Area C"
                    i == 0 ? "Branch C-1" : "Branch C-2"
                  when "Area D"
                    i == 0 ? "Branch D-1" : "Branch D-2"
                  when "Area E"
                    i == 0 ? "Branch E-1" : "Branch E-2"
                  when "Area F"
                    i == 0 ? "Branch F-1" : "Branch F-2"
                  when "Area G"
                    i == 0 ? "Branch G-1" : "Branch G-2"
                  when "Area H"
                    i == 0 ? "Branch H-1" : "Branch H-2"
                  end

    Branch.create!(
      area: area,
      name: branch_name,
      address: "#{i + 1}23 Sample Street, #{area.name}",
      phone: "0#{555 + i}#{sprintf('%06d', rand(1000000))}",
      open_hours: "平日 9:00-17:00\n土曜 9:00-12:00",
      default_capacity: 1
    )
  end
end

# Create Appointment Types
puts "Creating appointment types..."
appointment_types = [
  "住宅ローン相談",
  "資産運用相談",
  "保険相談",
  "Business Loan Consultation",
  "カードローン相談",
  "その他金融相談"
]

appointment_types.each do |type_name|
  AppointmentType.create!(name: type_name)
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
        booked_count: 0
      )
      
      current_time = slot_end
    end
  end
end

# Create some sample appointments
puts "Creating sample appointments..."

# Get some available slots
available_slots = Slot.available.limit(20)

sample_customers = [
  { name: "田中 太郎", furigana: "タナカタロウ", phone: "08012345678", email: "tanaka@example.com" },
  { name: "佐藤 花子", furigana: "サトウハナコ", phone: "09087654321", email: "sato@example.com" },
  { name: "鈴木 一郎", furigana: "スズキイチロウ", phone: "08011111111", email: nil },
  { name: "高橋 美香", furigana: "タカハシミカ", phone: "09022222222", email: "takahashi@example.com" },
  { name: "山田 次郎", furigana: "ヤマダジロウ", phone: "08033333333", email: nil }
]

available_slots.first(5).each_with_index do |slot, index|
  customer = sample_customers[index]
  
  appointment = Appointment.create!(
    branch: slot.branch,
    slot: slot,
    appointment_type: AppointmentType.all.sample,
    name: customer[:name],
    furigana: customer[:furigana],
    phone: customer[:phone],
    email: customer[:email],
    party_size: rand(1..4),
    purpose: "#{AppointmentType.all.sample.name}について詳しく相談したいです。",
    notes: index.even? ? "平日の夕方以降でお願いします。" : nil,
    status: ['booked', 'visited', 'needs_followup'].sample,
    accept_privacy: true
  )
  
  # Add admin memo to some appointments
  if index.odd?
    appointment.update!(admin_memo: "#{Date.current.strftime('%m/%d')} 電話でフォローアップ済み")
  end
end

# Slot status is automatically managed by booked_count

puts "Seed data created successfully!"
puts "Areas: #{Area.count}"
puts "Branches: #{Branch.count}"
puts "Appointment Types: #{AppointmentType.count}"
puts "Slots: #{Slot.count}"
puts "Sample Appointments: #{Appointment.count}"
