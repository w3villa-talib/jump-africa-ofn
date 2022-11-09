class AddColumnInspreeUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users, :parent_is_verifiy, :boolean, default: :false
    add_column :spree_users, :parent_default_image, :string
    add_column :spree_users, :parent_member_image, :string
  end
end
