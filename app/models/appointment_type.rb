class AppointmentType < ApplicationRecord
  # 関連
  has_many :appointments, dependent: :restrict_with_error
  
  # バリデーション
  validates :name, presence: true, uniqueness: true
end