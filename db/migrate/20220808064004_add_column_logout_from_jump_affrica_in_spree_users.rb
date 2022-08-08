class AddColumnLogoutFromJumpAffricaInSpreeUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users, :logout_from_jumpAfrica, :boolean, default: false
  end
end
