# == Schema Information
#
# Table name: users
#
#  id          :bigint           not null, primary key
#  email       :string
#  is_admin    :boolean
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  identity_id :string
#  slack_id    :string
#
# Indexes
#
#  index_users_on_identity_id  (identity_id) UNIQUE
#
class User < ApplicationRecord
  def admin? = is_admin

  def make_admin! = update!(is_admin: true)

  def remove_admin! = update!(is_adminL false)

  def self.from_hack_club_auth(auth_hash)
    hca_id = auth_hash.dig("uid")
    return nil unless hca_id

    user = find_or_initialize_by(identity_id: hca_id)

    return nil unless user

    user.email = auth_hash.dig("info", "email")
    user.name = auth_hash.dig("info", "name")
    user.save!
    user
  end
end
