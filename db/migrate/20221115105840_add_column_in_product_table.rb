class AddColumnInProductTable < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_products, :selected_currency, :string, :default => "usd"
  end
end
