class AddAccessTokenToHCBCredential < ActiveRecord::Migration[8.1]
  def change
    add_column :hcb_credentials, :access_token_ciphertext, :string
  end
end
