# frozen_string_literal: true

module CollaboratorsSpecHelper
  def index_expected_response(collaborators)
    collaborators.map do |collaborator|
      collaborator_attributes(collaborator)
    end
  end

  def collaborator_attributes(collaborator)
    {
      id: collaborator.id,
      name: collaborator.name,
      email: collaborator.email,
      company_id: collaborator.company_id
    }.stringify_keys
  end
end