class AddBrandingToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :primary_color, :string
    add_column :organizations, :secondary_color, :string
  end
end
