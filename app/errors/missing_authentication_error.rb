class MissingAuthenticationError < ApplicationError
  def status
    401
  end

  def detail
    "request is missing authentication"
  end
end
