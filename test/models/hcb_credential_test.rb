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
require "test_helper"

class HcbCredentialTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
