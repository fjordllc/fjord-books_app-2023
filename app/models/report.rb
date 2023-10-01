class Report < ApplicationRecord
  has_many :commnets, as: :commentable
  belongs_to :user
end
