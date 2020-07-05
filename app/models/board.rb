class Board < ApplicationRecord
  validates :title, presence: true
end
