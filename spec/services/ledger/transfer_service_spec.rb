require 'rails_helper'

RSpec.describe Ledger::TransferService, type: :service do
  let(:from_account) { create(:account, balance: 1000) }
  let(:to_account)   { create(:account, balance: 500) }
  let(:amount)       { 200 }
  let(:id_key)       { "tx_#{SecureRandom.uuid}" }

  describe ".call" do
    context "when the transfer is valid" do
      it "updates balances correctly and creates a ledger transaction" do
        expect {
          Ledger::TransferService.call(
            from_account: from_account,
            to_account: to_account,
            amount: amount,
            idempotency_key: id_key
          )
        }.to change { LedgerTransaction.count }.by(1)

        expect(from_account.reload.balance).to eq(800)
        expect(to_account.reload.balance).to eq(700)
      end

      it "creates exactly two balanced entries via the postgres trigger" do
        Ledger::TransferService.call(
          from_account: from_account,
          to_account: to_account,
          amount: amount,
          idempotency_key: id_key
        )

        entries = LedgerTransaction.last.entries
        expect(entries.count).to eq(2)
        expect(entries.sum(:amount)).to eq(0)
      end
    end

    context "when funds are insufficient" do
      let(:massive_amount) { 5000 }

      it "raises an error and does not change balances" do
        expect {
          Ledger::TransferService.call(
            from_account: from_account,
            to_account: to_account,
            amount: massive_amount,
            idempotency_key: id_key
          )
        }.to raise_error("Insufficient funds")

        expect(from_account.reload.balance).to eq(1000)
        expect(to_account.reload.balance).to eq(500)
      end
    end

    context "concurrency and idempotency" do
      it "is thread-safe and prevents double spending" do
        from = create(:account, balance: 100)
        to = create(:account, balance: 0)
        key = "unique-req-123"

        # Run 5 simultaneous attempts
        threads = 5.times.map do
          Thread.new do
            # We use a fresh database connection for each thread to simulate real world
            ActiveRecord::Base.connection_pool.with_connection do
              Ledger::TransferService.call(
                from_account: from, 
                to_account: to, 
                amount: 100, 
                idempotency_key: key
              )
            end
          end
        end
        threads.each(&:join)

        expect(from.reload.balance).to eq(0)
        expect(to.reload.balance).to eq(100)
        expect(LedgerTransaction.count).to eq(1) 
      end
    end
  end
end