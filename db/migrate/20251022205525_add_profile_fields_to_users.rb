class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :bio, :text
    add_column :users, :skills, :text
    add_column :users, :hourly_rate, :decimal
    add_column :users, :portfolio_url, :string
    add_column :users, :twitter_url, :string
    add_column :users, :linkedin_url, :string
    add_column :users, :available_for_hire, :boolean
    add_column :users, :service_categories, :text
  end
end
