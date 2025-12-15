# == Schema Information
#
# Table name: topups
#
#  id           :bigint           not null, primary key
#  amount_cents :integer
#  slug         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  cdg_id       :string
#  don_id       :string           not null
#  txn_id       :string           not null
#
class Topup < ApplicationRecord
  validates :txn_id, :don_id, :cdg_id, presence: true
end
