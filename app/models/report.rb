# frozen_string_literal: true

class Report < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
  belongs_to :user

  validates :title, presence: true
  validates :content, presence: true
end
