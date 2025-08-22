class Branch < ApplicationRecord
  # 関連
  belongs_to :area
  has_many :slots, dependent: :destroy
  has_many :appointments, dependent: :destroy
  
  # バリデーション
  validates :name, presence: true
  validates :address, presence: true
  validates :phone, presence: true,
                    format: { with: /\A\d{10,11}\z/, message: "は10〜11桁の数字で入力してください" }
  validates :open_hours, presence: true
end