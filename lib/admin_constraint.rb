class AdminConstraint
  def self.allow?(request, _permission = nil)
    user_id = request.session[:user_id]
    return false unless user_id

    user = User.find_by(id: user_id)
    user&.admin?
  end

  def matches?(request)
    self.class.allow?(request)
  end
end
