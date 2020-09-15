# frozen_string_literal: true

module CompaniesSpecHelper
  include CollaboratorsSpecHelper

  def index_expected_response(companies)
    companies.map do |company|
      company_attributes(company)
    end
  end

  def company_attributes(company)
    {
      id: company.id,
      name: company.name
    }.stringify_keys
  end

  def show_expected_response(company, collaborators = [])
    json = company_attributes(company)
    json["collaborators"] = collaborators_without_company(collaborators)
    json
  end
end
