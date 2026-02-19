class AddLedgerBalanceTrigger < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION validate_transaction_balance() RETURNS trigger AS $$
      BEGIN
        IF (SELECT SUM(amount) FROM entries WHERE ledger_transaction_id = NEW.ledger_transaction_id) != 0 THEN
          RAISE EXCEPTION 'Transaction is unbalanced for ID %', NEW.ledger_transaction_id;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE CONSTRAINT TRIGGER ensure_balance
      AFTER INSERT ON entries
      DEFERRABLE INITIALLY DEFERRED
      FOR EACH ROW EXECUTE FUNCTION validate_transaction_balance();
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS ensure_balance ON entries"
  end
end
