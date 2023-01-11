class AddColumnStatusInSpreeCountry < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_countries, :status, :boolean, default: false
  end
end
