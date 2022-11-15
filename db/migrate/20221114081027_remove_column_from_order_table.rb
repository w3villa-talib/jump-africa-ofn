class RemoveColumnFromOrderTable < ActiveRecord::Migration[6.1]
  def change
    remove_column :spree_orders, :payment_by
    remove_column :spree_orders, :payment_currency
    remove_column :spree_orders, :wallet_balance
    remove_column :spree_orders, :currency_id
  end
end
