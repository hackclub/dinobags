class CreateTopups < ActiveRecord::Migration[8.1]
  def change
    create_table :topups do |t|
      t.string :txn_id, null: false
      t.string :don_id, null: false
      t.string :slug
      t.integer :amount_cents

      t.timestamps
    end
  end
end
