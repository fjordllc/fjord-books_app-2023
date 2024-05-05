# frozen_string_literal: true

class ReportMention < ApplicationRecord
  belongs_to :mentioning, class_name: 'Report'
  belongs_to :mentioned, class_name: 'Report'

  validates :mentioned_id, uniqueness: { scope: :mentioning_id }
end
