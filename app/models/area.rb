class Area < ApplicationRecord
  # 関連
  has_many :branches, dependent: :destroy

  # バリデーション
  validates :name, presence: true, uniqueness: true
  validates :display_order, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :is_active, inclusion: { in: [true, false] }

  # スコープ
  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(:display_order) }
  scope :active_ordered, -> { active.ordered }

  # インスタンスメソッド
  def jurisdiction_list
    return [] if jurisdiction.blank?
    jurisdiction.split(/[、,]/).map(&:strip).reject(&:blank?)
  end
end