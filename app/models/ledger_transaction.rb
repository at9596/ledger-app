class LedgerTransaction < ApplicationRecord
  has_many :entries
end
