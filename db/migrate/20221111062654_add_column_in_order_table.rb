class AddColumnInOrderTable < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_orders, :payment_by, :string
    add_column :spree_orders, :payment_currency, :string
    add_column :spree_orders, :wallet_balance, :decimal, precision: 32, scale: 16
    add_column :spree_orders, :currency_id, :integer
  end
end
