# frozen_string_literal: true

class User < ApplicationRecord
  has_one_attached :avatar
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :avatar, attached: true, content_type: { in: ['image/png', 'image/jpeg', 'image/gif'], message: 'はpng, jpg, jpeg, gif のいずれかの形式にして下さい。' }
end
