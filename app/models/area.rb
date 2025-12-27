class Area < ApplicationRecord
  # 関連
  has_many :branches, dependent: :destroy
  
  # バリデーション
  validates :name, presence: true, uniqueness: true
end