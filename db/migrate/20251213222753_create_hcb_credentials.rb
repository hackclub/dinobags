class CreateHcbCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :hcb_credentials do |t|
      t.string :base_url
      t.string :client_secret_ciphertext
      t.string :redirect_uri
      t.string :refresh_token_ciphertext
      t.string :client_id

      t.timestamps
    end
  end
end
