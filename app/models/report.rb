# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
# 言及している日報id（mentioning_report_id)を目印に、言及されている日報(mentioning_report_id)を取得するためのアソシエーション
  has_many :mentioning_relationships, # ↑を取得するための関連付けに専用の名前をつける
           class_name: 'Mention', # ↑で名付けたのはmentionモデルのことだよ〜
           foreign_key: 'mentioning_report_id', # 目印にするのは言及している側の日報
           dependent: :destroy

# 言及している側の日報id（mentioning_report_id)を元に、mentioning_relationshipsを通して、言及されている日報id（mentioned_report_id)を取得できる
  has_many :mentioning_reports, through: :mentioning_relationships, source: :mentioned_report

# 言及されている日報id（mentioned_report_id)を目印に、言及している側の日報(mentioning_report_id)を取得するためのアソシエーション
  has_many :mentioned_relationships, # ↑を取得するための関連付けに専用の名前をつける
           class_name: 'Mention', # ↑で名付けたのはmentionモデルのことだよ〜
           foreign_key: 'mentioned_report_id', # 目印にするのは言及されている側の日報
           dependent: :destroy
 # 言及されている側の日報id（mentioned_report_id)を元に、mentioned_relationshipsを通して、言及している日報id（mentioning_report_id)を取得できる
  has_many :mentioned_reports, through: :mentioned_relationships, source: :mentioning_report

  validates :title, presence: true
  validates :content, presence: true

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end
end
