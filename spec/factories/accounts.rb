# FactoryBot.define do
#   factory :account do
#     balance { 0 }
#   end

#   factory :ledger_transaction do
#     idempotency_key { SecureRandom.uuid }
#   end

#   factory :entry do
#     association :ledger_transaction
#     association :account
#     amount { 0 }
#   end
# end

FactoryBot.define do
  factory :account do
    # These satisfy the PG::NotNullViolation
    account_type { "asset" } 
    currency     { "USD" }
    balance      { 0 }
    

    sequence(:name) { |n| "Account #{n}" }
  end

  factory :ledger_transaction do
    idempotency_key { SecureRandom.uuid }
  end

  factory :entry do
    association :ledger_transaction
    association :account
    amount { 0 }
  end
end