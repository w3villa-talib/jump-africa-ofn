class AddColumnInUserTable < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users, :parent_id, :integer
  end
end
