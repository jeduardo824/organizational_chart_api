# frozen_string_literal: true

class InvalidRequest < StandardError
  attr_reader :message, :status

  def initialize(message = nil, status = nil)
    @message = message || "Something went wrong"
    @status = status || :bad_request
  end
end
