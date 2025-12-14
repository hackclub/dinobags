# == Schema Information
#
# Table name: hcb_credentials
#
#  id                       :bigint           not null, primary key
#  access_token_ciphertext  :string
#  base_url                 :string
#  client_secret_ciphertext :string
#  redirect_uri             :string
#  refresh_token_ciphertext :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  client_id                :string
#
class HCBCredential < ApplicationRecord
  has_encrypted :access_token
  has_encrypted :client_secret
  has_encrypted :refresh_token
end
