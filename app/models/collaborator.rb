# frozen_string_literal: true

class Collaborator < ApplicationRecord
  REGEX_EMAIL = /[^\s]@[^\s]/

  belongs_to :company
  belongs_to :manager, class_name: "Collaborator", optional: true
  has_many :managed, class_name: "Collaborator", foreign_key: "manager_id"

  validates :name, presence: true
  validates :email, format: {
    with: REGEX_EMAIL, message: "is invalid"
  }, uniqueness: { case_sensitive: false }
end
