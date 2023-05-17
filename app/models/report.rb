# frozen_string_literal: true

class Report < ApplicationRecord
  HOST_REGEXP = %r{http://localhost:3000/reports/(\d+)}

  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :mentioning_relationships,
           class_name: 'Mention',
           foreign_key: 'mentioning_report_id',
           inverse_of: :mentioning_report,
           dependent: :destroy
  has_many :mentioning_reports, through: :mentioning_relationships, source: :mentioned_report
  has_many :mentioned_relationships,
           class_name: 'Mention',
           foreign_key: 'mentioned_report_id',
           inverse_of: :mentioned_report,
           dependent: :destroy
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
