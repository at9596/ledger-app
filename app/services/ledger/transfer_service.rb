module Ledger
  class TransferService
    def self.call(from_account:, to_account:, amount:, idempotency_key:)
      # 1. Quick check before starting a heavy transaction
      return if LedgerTransaction.exists?(idempotency_key: idempotency_key)

      ActiveRecord::Base.transaction do
        # 2. Lock accounts to prevent double spending
        # Sorting by ID prevents "Deadlock" errors
        [from_account, to_account].sort_by(&:id).each(&:lock!)

        # 3. Create the transaction record
        tx = LedgerTransaction.create!(
          description: "Transfer from #{from_account.id} to #{to_account.id}",
          idempotency_key: idempotency_key
        )

        # 4. Check funds AFTER locking
        raise "Insufficient funds" if from_account.balance < amount

        # 5. Create entries
        tx.entries.create!(account: from_account, amount: -amount)
        tx.entries.create!(account: to_account, amount: amount)

        # 6. Update balances (use update! to trigger cache clearing/validations)
        from_account.update!(balance: from_account.balance - amount)
        to_account.update!(balance: to_account.balance + amount)
      end
    rescue ActiveRecord::RecordNotUnique
      nil
    end
  end
end