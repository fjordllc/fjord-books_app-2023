class Report < ApplicationRecord
  has_many :commnets, as: :commentable
end
