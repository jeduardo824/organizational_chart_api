# frozen_string_literal: true

class Collaborator < ApplicationRecord
  REGEX_EMAIL = /[^\s]@[^\s]/

  belongs_to :company

  validates :name, presence: true
  validates :email, format: {
    with: REGEX_EMAIL, message: "is invalid"
  }, uniqueness: { case_sensitive: false }
end
