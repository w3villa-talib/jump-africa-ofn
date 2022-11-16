class AddColumnInPaymentTable < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_payments, :payment_currency, :string
    add_column :spree_payments, :wallet_balance, :decimal, precision: 32, scale: 16
    add_column :spree_payments, :currency_id, :integer
    add_column :spree_payments, :rate, :decimal, precision: 8, scale: 2
  end
end
