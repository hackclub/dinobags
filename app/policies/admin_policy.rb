class AdminPolicy < ApplicationPolicy
  def access?
    user&.admin?
  end

  def access_jobs?
    user.admin?
  end
end
