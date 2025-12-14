class AdminPolicy < ApplicationPolicy
  def access?
    user&.admin?
  end
end
