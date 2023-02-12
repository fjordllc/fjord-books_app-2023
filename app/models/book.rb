# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy

  mount_uploader :picture, PictureUploader
end
