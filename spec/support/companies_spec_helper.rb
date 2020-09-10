# frozen_string_literal: true

module CompaniesSpecHelper
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
end
