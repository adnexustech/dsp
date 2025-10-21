class AddCreditsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :credits_balance, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
