# frozen_string_literal: true

class FindCollaboratorsService
  TYPE_ERROR_MESSAGE = "Information type is not valid"
  DEPTH = 2

  def initialize(collaborator, info_type)
    @collaborator = collaborator
    @info_type = info_type
  end

  def self.call!(collaborator:, info_type:)
    new(collaborator, info_type).call
  end

  def call
    case info_type.to_sym
    when :peers
      collaborator.peers
    when :managed
      collaborator.managed
    when :second_level_managed
      second_level_managed
    else
      raise InvalidRequest.new(TYPE_ERROR_MESSAGE, :bad_request)
    end
  end

  private
    attr_reader :collaborator, :info_type

    def second_level_managed
      descendants_query.where("depth = ?", DEPTH)
    end

    def descendants_query
      query = CollaboratorsQuery.new(collaborator: collaborator)

      query.descendants
    end
end
