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

# Create Branches (正しい支店データ)
puts "Creating branches..."
branches_data = [
  # 伊豆太陽地区
  { area: '伊豆太陽地区', code: '113', name: '稲取支店', address: '賀茂郡東伊豆町稲取2804', phone: '0557-95-1211', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '116', name: '熱川支店', address: '賀茂郡東伊豆町奈良本241', phone: '0557-23-1255', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '114', name: '河津桜支店', address: '賀茂郡河津町笹原341', phone: '0558-32-0303', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '107', name: '下田支店', address: '下田市東本郷1-12-8', phone: '0558-22-0814', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '103', name: '下田北支店', address: '下田市河内404-1', phone: '0558-22-0319', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '104', name: '白浜支店', address: '下田市白浜1259-6', phone: '0558-22-0861', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '123', name: '竹麻支店', address: '賀茂郡南伊豆町青市1027-1', phone: '0558-62-0305', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '125', name: '南中支店', address: '賀茂郡南伊豆町上賀茂5-1', phone: '0558-62-0511', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '133', name: '松崎支店', address: '賀茂郡松崎町江奈171-1', phone: '0558-42-0119', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '135', name: '仁科支店', address: '賀茂郡西伊豆町仁科1296-1', phone: '0558-52-0036', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '伊豆太陽地区', code: '137', name: '宇久須支店', address: '賀茂郡西伊豆町宇久須424-1', phone: '0558-55-0236', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },

  # 三島函南地区
  { area: '三島函南地区', code: '201', name: '三島支店', address: '三島市谷田字城の内141-1', phone: '055-971-8214', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '202', name: '北上支店', address: '三島市幸原町1-13-19', phone: '055-986-3000', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '204', name: '中郷支店', address: '三島市中島269-1', phone: '055-977-1430', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '207', name: '大社前支店', address: '三島市大宮町3-6-5', phone: '055-975-0093', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '212', name: '新谷支店', address: '三島市新谷155-8', phone: '055-972-5757', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '221', name: '函南支店', address: '田方郡函南町大土肥50', phone: '055-978-2580', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '三島函南地区', code: '223', name: '仁田支店', address: '田方郡函南町仁田181-1', phone: '055-978-2582', open_hours: '8:30～15:00', default_capacity: 3 },

  # 伊豆の国地区
  { area: '伊豆の国地区', code: '302', name: '韮山支店', address: '伊豆の国市四日町241-1', phone: '055-949-1342', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '313', name: '南部支店', address: '伊豆の国市南條802', phone: '055-949-3217', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '305', name: '長岡支店', address: '伊豆の国市長岡1117-1', phone: '055-948-1335', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '306', name: '江間支店', address: '伊豆の国市南江間800-1', phone: '055-948-6060', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '307', name: '田中支店', address: '伊豆の国市田京295-1', phone: '0558-76-1388', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '331', name: '土肥支店', address: '伊豆市土肥469-1', phone: '0558-98-1038', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '354', name: '修善寺支店', address: '伊豆市柏久保634-5', phone: '0558-72-0134', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '356', name: '狩野支店', address: '伊豆市青羽根140-3', phone: '0558-87-0400', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '360', name: '八幡支店', address: '伊豆市八幡756-1', phone: '0558-83-0029', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '伊豆の国地区', code: '321', name: '戸田支店', address: '沼津市戸田1306-1', phone: '0558-94-3006', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },

  # あいら伊豆地区
  { area: 'あいら伊豆地区', code: '402', name: '富士見支店', address: '伊東市玖須美元和田730', phone: '0557-37-3208', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '404', name: '吉田支店', address: '伊東市吉田349', phone: '0557-45-0679', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '408', name: '伊東支店', address: '伊東市桜ガ丘2-2-10', phone: '0557-37-7140', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '409', name: '荻支店', address: '伊東市荻154-1', phone: '0557-37-2958', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '410', name: '伊豆高原支店', address: '伊東市八幡野1189-163', phone: '0557-53-0016', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '420', name: '宇佐美支店', address: '伊東市宇佐美1641-1', phone: '0557-48-9301', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '421', name: '下多賀支店', address: '熱海市下多賀894-1', phone: '0557-68-3111', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: 'あいら伊豆地区', code: '424', name: '熱海支店', address: '熱海市小嵐町1-23', phone: '0557-82-3188', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },

  # なんすん地区
  { area: 'なんすん地区', code: '015', name: '西浦みかん支店', address: '沼津市西浦平沢6-4', phone: '055-942-2121', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '018', name: '沼津支店', address: '沼津市下香貫字上障子415-1', phone: '055-931-0455', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '002', name: '静浦支店', address: '沼津市獅子浜52', phone: '055-931-3053', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '017', name: '山王通り支店', address: '沼津市平町6-18', phone: '055-951-0315', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '003', name: '大平支店', address: '沼津市大平1816-1', phone: '055-931-1219', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '004', name: '大岡支店', address: '沼津市大岡2431', phone: '055-921-0459', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '005', name: '金岡支店', address: '沼津市東熊堂600-1', phone: '055-921-4456', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '014', name: '光長寺前支店', address: '沼津市岡宮1071-1', phone: '055-922-6100', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '006', name: '愛鷹支店', address: '沼津市東原337-2', phone: '055-966-2491', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '007', name: '浮島支店', address: '沼津市平沼545-2', phone: '055-966-2050', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '008', name: '原支店', address: '沼津市原349-3', phone: '055-966-0600', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '021', name: '片浜支店', address: '沼津市大諏訪247-4', phone: '055-962-0457', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '031', name: '清水支店', address: '駿東郡清水町堂庭202', phone: '055-975-4723', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '032', name: '徳倉支店', address: '駿東郡清水町徳倉977-1', phone: '055-931-5047', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '034', name: '長沢支店', address: '駿東郡清水町長沢706-1', phone: '055-971-6024', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '054', name: 'ゆうすい支店', address: '駿東郡清水町伏見639-1', phone: '055-972-2522', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '051', name: '長泉支店', address: '駿東郡長泉町下土狩1029-1', phone: '055-986-1850', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '052', name: '下土狩支店', address: '駿東郡長泉町下土狩1293-1', phone: '055-986-5575', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '055', name: '中土狩支店', address: '駿東郡長泉町中土狩878-4', phone: '055-987-2232', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '056', name: '納米里支店', address: '駿東郡長泉町納米里78-5', phone: '055-987-9717', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '061', name: 'すその富岡支店', address: '裾野市御宿690', phone: '055-997-1226', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '062', name: '裾野西支店', address: '裾野市伊豆島田711-1', phone: '055-992-2140', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '063', name: '泉支店', address: '裾野市平松453', phone: '055-992-2020', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '064', name: '深良支店', address: '裾野市深良657', phone: '055-997-0065', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: 'なんすん地区', code: '065', name: '須山支店', address: '裾野市須山1593-1', phone: '055-998-0003', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },

  # 御殿場地区
  { area: '御殿場地区', code: '502', name: '富士岡支店', address: '御殿場市中山483-7', phone: '0550-87-1012', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '503', name: '神山支店', address: '御殿場市神山853-1', phone: '0550-87-0009', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '504', name: '竈支店', address: '御殿場市竈1032', phone: '0550-82-0722', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '505', name: '原里支店', address: '御殿場市永塚350-1', phone: '0550-89-0252', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '506', name: '印野支店', address: '御殿場市印野1666', phone: '0550-89-0649', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '507', name: '玉穂支店', address: '御殿場市茱萸沢691', phone: '0550-89-0223', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '508', name: '御殿場支店', address: '御殿場市二枚橋251-5', phone: '0550-82-0256', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '509', name: '新橋支店', address: '御殿場市新橋1962-1', phone: '0550-82-2565', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '510', name: '高根支店', address: '御殿場市山尾田138-2', phone: '0550-82-1001', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '514', name: 'ぐみざわ支店', address: '御殿場市茱萸沢5', phone: '0550-82-2830', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '516', name: 'はなみずき支店', address: '御殿場市東田中2-10-1', phone: '0550-84-5522', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '511', name: '北郷支店', address: '駿東郡小山町一色333-1', phone: '0550-78-0334', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '512', name: '足柄支店', address: '駿東郡小山町竹之下247-1', phone: '0550-76-0278', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: '御殿場地区', code: '513', name: '小山支店', address: '駿東郡小山町藤曲56-3', phone: '0550-76-4600', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },

  # 富士地区
  { area: '富士地区', code: '601', name: '富士中央支店', address: '富士市青島200-1', phone: '0545-51-2122', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: '富士地区', code: '602', name: '元吉原支店', address: '富士市田中新田262-1', phone: '0545-33-0730', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '606', name: '須津支店', address: '富士市中里1143-2', phone: '0545-34-0810', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '607', name: '原田支店', address: '富士市原田178-1', phone: '0545-52-1945', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '608', name: '今泉支店', address: '富士市今泉2-6-47', phone: '0545-52-1800', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '609', name: '富士北支店', address: '富士市一色500-11', phone: '0545-21-1181', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: '富士地区', code: '610', name: '島田支店', address: '富士市津田町120', phone: '0545-52-0201', open_hours: '8:30～12:00、13:00～15:00', default_capacity: 3 },
  { area: '富士地区', code: '611', name: '伝法支店', address: '富士市伝法2800-1', phone: '0545-52-5110', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '613', name: '大淵支店', address: '富士市大淵2892-5', phone: '0545-35-0205', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '614', name: '鷹岡支店', address: '富士市鷹岡本町1-3', phone: '0545-71-2200', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '615', name: '天間支店', address: '富士市天間642-1', phone: '0545-71-2203', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '616', name: '丘支店', address: '富士市厚原2312-7', phone: '0545-71-4452', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '617', name: '吉永支店', address: '富士市比奈1448', phone: '0545-34-0815', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '621', name: '富士支店', address: '富士市水戸島187-1', phone: '0545-61-3080', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '623', name: '竪堀支店', address: '富士市松本12-1', phone: '0545-61-9166', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '624', name: '田子浦支店', address: '富士市中丸758-1', phone: '0545-61-2811', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '627', name: '岩松支店', address: '富士市松岡2392-1', phone: '0545-61-0960', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '628', name: '橋下支店', address: '富士市松岡1078', phone: '0545-61-0916', open_hours: '8:30～12:30、13:30～15:00', default_capacity: 3 },
  { area: '富士地区', code: '632', name: '富士川支店', address: '富士市中之郷724', phone: '0545-81-1025', open_hours: '8:30～15:00', default_capacity: 3 },

  # 富士宮地区
  { area: '富士宮地区', code: '702', name: '富士宮北部支店', address: '富士宮市村山1510', phone: '0544-26-5168', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '703', name: '大宮支店', address: '富士宮市錦町4-4', phone: '0544-26-3177', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '704', name: '富士宮富丘支店', address: '富士宮市青木326-1', phone: '0544-26-5171', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '706', name: '北山支店', address: '富士宮市北山1529-15', phone: '0544-58-0456', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '707', name: '白糸支店', address: '富士宮市原1886', phone: '0544-54-0012', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '709', name: '上野支店', address: '富士宮市下条438-1', phone: '0544-58-0567', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '710', name: '富士根支店', address: '富士宮市西小泉町55-1', phone: '0544-26-2183', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '716', name: '富士宮中央支店', address: '富士宮市外神東町117', phone: '0544-58-5300', open_hours: '8:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '718', name: '富士宮東支店', address: '富士宮市弓沢町197-3', phone: '0544-26-8120', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '730', name: '芝川支店', address: '富士宮市長貫1095-18', phone: '0544-65-0900', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 },
  { area: '富士宮地区', code: '740', name: '柚野支店', address: '富士宮市大鹿窪198-2', phone: '0544-66-0111', open_hours: '8:30～11:30、12:30～15:00', default_capacity: 3 }
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
