class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :slack_id
      t.boolean :admin
      t.string :identity_id

      t.timestamps
    end

    add_index :users, :identity_id, unique: true
  end
end
