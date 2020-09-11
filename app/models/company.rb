# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :collaborators, dependent: :destroy

  accepts_nested_attributes_for :collaborators

  validates :name, presence: true
end
