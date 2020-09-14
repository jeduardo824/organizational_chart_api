# frozen_string_literal: true

class ValidateManagerService
  ERRORS = {
    with_manager: "Collaborator already has manager",
    not_in_company: "The manager is not in the same company of the collaborator",
    below_hierarchy: "The manager is below the collaborator in the hierarchy"
  }

  def initialize(collaborator, manager)
    @collaborator = collaborator
    @manager = manager
  end

  def self.call!(collaborator:, manager:)
    new(collaborator, manager).call
  end

  def call
    collaborator_has_manager
    manager_not_in_same_company
    manager_below_hierarchy
  end

  private
    attr_reader :collaborator, :manager

    delegate :managed, to: :collaborator, prefix: true

    def collaborator_has_manager
      raise_exception!(ERRORS[:with_manager]) if collaborator.manager
    end

    def raise_exception!(message)
      raise InvalidRequest.new(message, :unprocessable_entity)
    end

    def manager_not_in_same_company
      not_same_company = collaborator.company != manager.company

      raise_exception!(ERRORS[:not_in_company]) if not_same_company
    end

    def manager_below_hierarchy
      return if collaborator_managed.empty?

      if collaborator_descendants.exists?(manager.id)
        raise_exception!(ERRORS[:below_hierarchy])
      end
    end

    def collaborator_descendants
      query = CollaboratorsQuery.new(collaborator: collaborator)

      query.descendants
    end
end
