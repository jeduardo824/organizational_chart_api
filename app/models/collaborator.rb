# frozen_string_literal: true

class Collaborator < ApplicationRecord
  REGEX_EMAIL = /[^\s]@[^\s]/

  belongs_to :company
  belongs_to :manager, class_name: "Collaborator", optional: true
  has_many :managed, class_name: "Collaborator", dependent: :nullify, foreign_key: "manager_id"

  validates :name, presence: true
  validates :email, format: {
    with: REGEX_EMAIL, message: "is invalid"
  }, uniqueness: { case_sensitive: false }

  def peers
    return [] unless manager

    managed_by_manager.where.not(id: id)
  end

  private

    def managed_by_manager
      manager.managed
    end
end
