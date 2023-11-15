# frozen_string_literal: true

class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :avatar, content_type: { in: ['image/png', 'image/jpeg', 'image/gif'], message: 'はpng, jpg, jpeg, gif のいずれかの形式にして下さい。' }
end
