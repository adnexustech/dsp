class CreateCreditTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :transaction_type, null: false
      t.text :description

      t.timestamps
    end

    add_index :credit_transactions, [:user_id, :created_at]
    add_index :credit_transactions, :transaction_type
  end
end
