# Seeds for Fuji-Izu Agricultural Cooperative Reservation System
# This creates initial data for testing and demonstration purposes

# Clear existing data
puts "Cleaning up existing data..."
Appointment.destroy_all
Slot.destroy_all
AppointmentType.destroy_all
Branch.destroy_all
Area.destroy_all

# Create Areas with new structure (8 areas)
puts "Creating areas..."
areas_data = [
  {
    name: "伊豆太陽地区",
    jurisdiction: "下田市、河津町、松崎町、西伊豆町、東伊豆町、南伊豆町",
    display_order: 1,
    is_active: true
  },
  {
    name: "三島函南地区",
    jurisdiction: "三島市、函南町",
    display_order: 2,
    is_active: true
  },
  {
    name: "伊豆の国地区",
    jurisdiction: "伊豆の国市、伊豆市、沼津市戸田地区",
    display_order: 3,
    is_active: true
  },
  {
    name: "あいら伊豆地区",
    jurisdiction: "熱海市、伊東市",
    display_order: 4,
    is_active: true
  },
  {
    name: "なんすん地区",
    jurisdiction: "沼津市、裾野市、長泉町、清水町",
    display_order: 5,
    is_active: true
  },
  {
    name: "御殿場地区",
    jurisdiction: "御殿場市、小山町",
    display_order: 6,
    is_active: true
  },
  {
    name: "富士地区",
    jurisdiction: "富士市",
    display_order: 7,
    is_active: true
  },
  {
    name: "富士宮地区",
    jurisdiction: "富士宮市",
    display_order: 8,
    is_active: true
  }
]

areas_data.each do |area_attrs|
  Area.create!(area_attrs)
end

# Create Branches (127 branches across 8 areas)
puts "Creating branches..."
branches_data = [
  # 伊豆太陽地区 (11 branches)
  { area: '伊豆太陽地区', code: '113', name: '稲取支店', address: '賀茂郡東伊豆町稲取2804', phone: '0557-95-1211', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '116', name: '熱川支店', address: '賀茂郡東伊豆町奈良本241', phone: '0557-23-1255', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '117', name: '片瀬支店', address: '賀茂郡東伊豆町片瀬8-1', phone: '0557-23-0311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '122', name: '下田中央支店', address: '下田市一丁目18-26', phone: '0558-22-0538', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '123', name: '下田駅前支店', address: '下田市東本郷一丁目5-5', phone: '0558-22-1124', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '124', name: '浜崎支店', address: '下田市三丁目13-16', phone: '0558-22-1125', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '125', name: '白浜支店', address: '下田市白浜1733-2', phone: '0558-22-5311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '126', name: '箕作支店', address: '下田市箕作74-2', phone: '0558-27-2211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '127', name: '朝日支店', address: '下田市立野117', phone: '0558-28-0211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '151', name: '松崎支店', address: '賀茂郡松崎町宮内253-1', phone: '0558-42-0540', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '152', name: '岩科支店', address: '賀茂郡松崎町岩科北側442-1', phone: '0558-42-0131', open_hours: '8:30～15:00', default_capacity: 3 },

  # 三島函南地区 (7 branches)
  { area: '三島函南地区', code: '201', name: '三島中央支店', address: '三島市大宮町二丁目1-41', phone: '055-975-1111', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '202', name: '北上支店', address: '三島市徳倉4-14-7', phone: '055-987-7001', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '203', name: '中郷支店', address: '三島市中島266-1', phone: '055-977-6200', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '204', name: '錦田支店', address: '三島市谷田藤久保241-9', phone: '055-971-7700', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '205', name: '箱根西麓支店', address: '三島市川原ケ谷301-1', phone: '055-984-1211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '211', name: '函南東部支店', address: '田方郡函南町間宮627-1', phone: '055-978-3131', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '212', name: '函南西部支店', address: '田方郡函南町平井1695-193', phone: '055-979-5511', open_hours: '8:30～15:00', default_capacity: 3 },

  # 伊豆の国地区 (10 branches)
  { area: '伊豆の国地区', code: '301', name: '大仁支店', address: '伊豆の国市大仁447-1', phone: '0558-76-1222', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '302', name: '田京支店', address: '伊豆の国市田京299-11', phone: '0558-76-0142', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '303', name: '戸田支店', address: '沼津市戸田466-1', phone: '0558-94-2311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '304', name: '土肥支店', address: '伊豆市土肥697-27', phone: '0558-98-1221', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '305', name: '修善寺支店', address: '伊豆市柏久保673-1', phone: '0558-72-1201', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '306', name: '中伊豆支店', address: '伊豆市上白岩1433-1', phone: '0558-83-2211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '307', name: '天城支店', address: '伊豆市市山550', phone: '0558-85-1211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '311', name: '韮山支店', address: '伊豆の国市四日町280-1', phone: '055-949-1201', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '321', name: '伊豆長岡支店', address: '伊豆の国市長岡1129', phone: '055-948-1215', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '322', name: '北伊豆支店', address: '伊豆の国市南條454-1', phone: '055-949-2211', open_hours: '8:30～15:00', default_capacity: 3 },

  # あいら伊豆地区 (8 branches)
  { area: 'あいら伊豆地区', code: '401', name: '熱海中央支店', address: '熱海市渚町12-5', phone: '0557-81-3131', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '402', name: '泉支店', address: '熱海市泉191-4', phone: '0557-81-2311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '403', name: '多賀支店', address: '熱海市下多賀495-28', phone: '0557-68-2311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '404', name: '網代支店', address: '熱海市網代304-2', phone: '0557-68-0125', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '411', name: '伊東中央支店', address: '伊東市大原一丁目3-6', phone: '0557-37-3135', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '412', name: '宇佐美支店', address: '伊東市宇佐美1807-1', phone: '0557-48-7200', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '413', name: '富戸支店', address: '伊東市富戸1103', phone: '0557-51-2311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '414', name: '対島支店', address: '伊東市吉田992-22', phone: '0557-45-1311', open_hours: '8:30～15:00', default_capacity: 3 },

  # なんすん地区 (25 branches)
  { area: 'なんすん地区', code: '501', name: '本店営業部', address: '沼津市御幸町16-1', phone: '055-962-1313', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '502', name: '中央支店', address: '沼津市新沢田町4-30', phone: '055-921-3211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '503', name: '新沢田支店', address: '沼津市新沢田町2-5', phone: '055-921-3177', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '504', name: '千本支店', address: '沼津市千本港町106-3', phone: '055-962-0312', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '505', name: '大岡支店', address: '沼津市大岡自由ケ丘1883-1', phone: '055-921-2211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '506', name: '沼津南支店', address: '沼津市柳町10-12', phone: '055-962-2155', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '507', name: '下香貫支店', address: '沼津市下香貫前原1481-1', phone: '055-933-5200', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '508', name: '西添支店', address: '沼津市西添町4-22', phone: '055-921-1237', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '509', name: '片浜支店', address: '沼津市今沢193-1', phone: '055-966-1212', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '510', name: '原支店', address: '沼津市原1840-1', phone: '055-966-0333', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '511', name: '浮島支店', address: '沼津市平沼833-1', phone: '055-966-4311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '512', name: '愛鷹支店', address: '沼津市岡一色764', phone: '055-926-1131', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '513', name: '金岡支店', address: '沼津市東椎路753', phone: '055-921-0211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '514', name: '大平支店', address: '沼津市大平1734-1', phone: '055-931-2311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '521', name: '裾野東支店', address: '裾野市佐野1641-6', phone: '055-992-0540', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '522', name: '裾野西支店', address: '裾野市伊豆島田811-2', phone: '055-997-0211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '523', name: '富岡支店', address: '裾野市富沢713-1', phone: '055-997-1311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '531', name: '長泉中央支店', address: '駿東郡長泉町下土狩1354-7', phone: '055-986-9600', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '532', name: '長泉北支店', address: '駿東郡長泉町中土狩524-1', phone: '055-988-7400', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '533', name: '長沢支店', address: '駿東郡長泉町納米里332', phone: '055-987-0222', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '534', name: '桃沢支店', address: '駿東郡長泉町元長窪894-45', phone: '055-986-0021', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '541', name: '清水町支店', address: '駿東郡清水町堂庭194-1', phone: '055-973-0211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '542', name: '清水町南支店', address: '駿東郡清水町玉川61-2', phone: '055-981-0211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '543', name: '湯川支店', address: '駿東郡清水町八幡20-1', phone: '055-931-1221', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '544', name: '柿田支店', address: '駿東郡清水町柿田174-1', phone: '055-975-1500', open_hours: '8:30～15:00', default_capacity: 3 },

  # 御殿場地区 (14 branches)
  { area: '御殿場地区', code: '601', name: '御殿場中央支店', address: '御殿場市萩原515-1', phone: '0550-82-0550', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '602', name: '御殿場駅前支店', address: '御殿場市新橋728-1', phone: '0550-83-3550', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '603', name: '御殿場東支店', address: '御殿場市東田中1689-5', phone: '0550-82-2266', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '604', name: '御殿場南支店', address: '御殿場市川島田924-10', phone: '0550-89-0505', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '605', name: '原里支店', address: '御殿場市川島田字下河原638-1', phone: '0550-89-1511', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '606', name: '富士岡支店', address: '御殿場市中山522-1', phone: '0550-87-0211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '607', name: '高根支店', address: '御殿場市中畑513-1', phone: '0550-87-1311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '608', name: '玉穂支店', address: '御殿場市茱萸沢1373-1', phone: '0550-89-1221', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '609', name: '印野支店', address: '御殿場市印野1648-23', phone: '0550-88-0211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '610', name: '上野支店', address: '御殿場市上小林1487-1', phone: '0550-89-0611', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '611', name: '小山中央支店', address: '駿東郡小山町小山71-3', phone: '0550-76-0511', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '612', name: '須走支店', address: '駿東郡小山町須走206-15', phone: '0550-75-2311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '613', name: '足柄支店', address: '駿東郡小山町一色483-1', phone: '0550-78-0511', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '614', name: '北郷支店', address: '駿東郡小山町生土559-1', phone: '0550-76-1231', open_hours: '8:30～15:00', default_capacity: 3 },

  # 富士地区 (19 branches)
  { area: '富士地区', code: '701', name: '富士中央支店', address: '富士市青島町195', phone: '0545-61-3030', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '702', name: '富士北支店', address: '富士市今泉3-13-21', phone: '0545-52-1155', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '703', name: '吉原支店', address: '富士市国久保二丁目1-25', phone: '0545-52-0537', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '704', name: '吉原南支店', address: '富士市鈴川中町16-5', phone: '0545-53-6911', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '705', name: '元吉原支店', address: '富士市五貫島203', phone: '0545-61-0202', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '706', name: '伝法支店', address: '富士市中丸264-1', phone: '0545-21-3500', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '707', name: '今泉支店', address: '富士市瓜島町82', phone: '0545-51-5011', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '708', name: '神戸支店', address: '富士市神戸48-3', phone: '0545-32-1311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '709', name: '広見支店', address: '富士市厚原98-1', phone: '0545-71-1311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '710', name: '大淵支店', address: '富士市大淵3213-5', phone: '0545-36-0211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '711', name: '富士見台支店', address: '富士市伝法2853', phone: '0545-51-6088', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '712', name: '富士川支店', address: '富士市岩淵855-15', phone: '0545-81-0531', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '713', name: '松野支店', address: '富士市松岡1112-1', phone: '0545-85-2311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '714', name: '岩松支店', address: '富士市岩本309', phone: '0545-61-0121', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '715', name: '田子浦支店', address: '富士市中丸1181-1', phone: '0545-61-0041', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '716', name: '鷹岡支店', address: '富士市厚原字中河原547-1', phone: '0545-71-1331', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '717', name: '富士南支店', address: '富士市水戸島86-1', phone: '0545-66-0211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '718', name: '天間支店', address: '富士市天間1322', phone: '0545-71-1511', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '719', name: '富士東支店', address: '富士市蓼原1212-1', phone: '0545-21-0315', open_hours: '8:30～15:00', default_capacity: 3 },

  # 富士宮地区 (11 branches) - Corrected name to match Area name
  { area: '富士宮地区', code: '801', name: '富士宮中央支店', address: '富士宮市若の宮町470', phone: '0544-26-6211', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '802', name: '富士宮東支店', address: '富士宮市杉田299-1', phone: '0544-26-7500', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '803', name: '富士宮北支店', address: '富士宮市淀師463-2', phone: '0544-26-4151', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '804', name: '富士根支店', address: '富士宮市内房2740-1', phone: '0544-26-3131', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '805', name: '富士根南支店', address: '富士宮市山本309-1', phone: '0544-58-1511', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '806', name: '大宮支店', address: '富士宮市宮原450-1', phone: '0544-27-2121', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '807', name: '北山支店', address: '富士宮市北山4705', phone: '0544-58-0211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '808', name: '上井出支店', address: '富士宮市上井出2317', phone: '0544-54-0311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '809', name: '白糸支店', address: '富士宮市内野1697-5', phone: '0544-54-1211', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '810', name: '上野支店', address: '富士宮市上稲子1503', phone: '0544-56-0311', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '811', name: '芝川支店', address: '富士宮市長貫747-1', phone: '0544-65-0211', open_hours: '8:30～15:00', default_capacity: 3 }
]

branches_data.each do |branch_attrs|
  area = Area.find_by!(name: branch_attrs[:area])
  branch_attrs.delete(:area)

  # Remove hyphens from phone numbers to match validation (10-11 digits)
  branch_attrs[:phone] = branch_attrs[:phone].gsub(/[-()]/, '')

  Branch.create!(
    area: area,
    code: branch_attrs[:code],
    name: branch_attrs[:name],
    address: branch_attrs[:address],
    phone: branch_attrs[:phone],
    open_hours: branch_attrs[:open_hours],
    default_capacity: branch_attrs[:default_capacity]
  )
end

# Create Appointment Types (変更なし)
puts "Creating appointment types..."
appointment_types = [
  "住宅ローン相談",
  "資産運用相談",
  "保険相談",
  "農業融資相談",
  "カードローン相談",
  "その他金融相談"
]

appointment_types.each do |type_name|
  AppointmentType.create!(name: type_name)
end

# NOTE: Slots と Appointments は自動生成またはユーザーアクションで作成されます

puts "Seed data created successfully!"
puts "Areas: #{Area.count}"
puts "Branches: #{Branch.count}"
puts "Appointment Types: #{AppointmentType.count}"
puts ""
puts "Next step: Run 'bin/rails slots:generate_initial' to create time slots for all branches"
