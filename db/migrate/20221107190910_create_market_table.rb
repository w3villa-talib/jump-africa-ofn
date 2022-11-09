class CreateMarketTable < ActiveRecord::Migration[6.1]
  def change
    create_table :market_tables do |t|
      t.float :value
      t.string :tar_unit
      t.string :symbol

      t.timestamps
    end
  end
end
