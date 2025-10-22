class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :slug
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.string :subscription_plan
      t.string :subscription_status
      t.decimal :credits_balance
      t.integer :owner_id

      t.timestamps
    end
    add_index :organizations, :owner_id
  end
end
