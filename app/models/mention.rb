# frozen_string_literal: true

class Mention < ApplicationRecord
  belongs_to :mention_from, class_name: 'Report'
  belongs_to :mention_to, class_name: 'Report'
end