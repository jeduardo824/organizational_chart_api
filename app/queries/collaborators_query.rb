# frozen_string_literal: true

class CollaboratorsQuery
  def initialize(collaborator:)
    @collaborator = collaborator
  end

  def descendants
    self_and_descendants.where.not(id: id)
  end

  def self_and_descendants(columns = Collaborator.column_names)
    cols = columns.join(", ")
    cols_mapping = columns.map { |col| "collaborators.#{col}" }.join(", ")

    Collaborator.from <<~SQL
      (WITH RECURSIVE collaborators_tree(#{cols}, depth, path) AS (
        SELECT #{cols}, 0, ARRAY[id]
        FROM collaborators
        WHERE id = '#{id}'
      UNION ALL
        SELECT #{cols_mapping}, depth + 1, path || collaborators.id
        FROM collaborators_tree
        JOIN
          collaborators ON collaborators.manager_id = collaborators_tree.id
        WHERE NOT
          collaborators.id = ANY(path)
      ) SELECT * FROM collaborators_tree) AS collaborators
    SQL
  end

  private
    def id
      @_id ||= @collaborator.id
    end
end
