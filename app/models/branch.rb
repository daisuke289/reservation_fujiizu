class Branch < ApplicationRecord
  # 関連
  belongs_to :area
  has_many :slots, dependent: :destroy
  has_many :appointments, dependent: :destroy

  # バリデーション
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :address, presence: true
  validates :phone, presence: true,
                    format: { with: /\A\d{10,11}\z/, message: "は10〜11桁の数字で入力してください" }
  validates :open_hours, presence: true
  validates :default_capacity, presence: true,
                               numericality: { greater_than_or_equal_to: 1, only_integer: true }
end