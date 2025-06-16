# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :active_mentions, class_name: 'ReportMention', foreign_key: :mentioning_id, dependent: :destroy, inverse_of: :mentioning
  has_many :mentioning_reports, through: :active_mentions, source: :mentioned

  has_many :passive_mentions, class_name: 'ReportMention', foreign_key: :mentioned_id, dependent: :destroy, inverse_of: :mentioned
  has_many :mentioned_reports, through: :passive_mentions, source: :mentioning

  validates :title, presence: true
  validates :content, presence: true

  after_save :save_mentions

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  private

  MENTION_REGEXP = %r{http://localhost:3000/reports/(\d+)}
  def save_mentions
    active_mentions.destroy_all
    ids = content.to_s.scan(MENTION_REGEXP).flatten.uniq
    reports = Report.where(id: ids).where.not(id:)
    self.mentioning_reports += reports
  end
end
