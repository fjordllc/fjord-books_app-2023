# frozen_string_literal: true

class ReportMention < ApplicationRecord
  belongs_to :mention_to, class_name: 'Report'
  belongs_to :mentioned_by, class_name: 'Report'

  validates :mentioned_by_id, uniqueness: { scope: :mention_to_id }
end
