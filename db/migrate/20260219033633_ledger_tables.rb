class LedgerTables < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :account_type, null: false # asset, liability, equity, revenue, expense
      t.string :currency, limit: 3, default: "USD", null: false
      t.decimal :balance, precision: 19, scale: 4, default: 0, null: false
      t.timestamps
    end

    create_table :ledger_transactions do |t|
      t.string :description
      t.string :idempotency_key, index: { unique: true }
      t.jsonb :metadata # For audit trails
      t.timestamps
    end

    create_table :entries do |t|
      t.references :ledger_transaction, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.timestamps
    end
    execute "ALTER TABLE entries ADD CONSTRAINT amount_nonzero CHECK (amount <> 0)"
  end
end
