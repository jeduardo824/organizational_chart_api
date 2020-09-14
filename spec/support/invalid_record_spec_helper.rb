# frozen_string_literal: true

module RequestExceptionSpecHelper
  def exception_body(message)
    {
      message: message
    }.stringify_keys
  end
end
