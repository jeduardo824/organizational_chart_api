# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/companies", type: :request do
  include CompaniesSpecHelper

  let(:company_name) { "A Company Name" }
  let(:valid_attributes) { { name: company_name } }
  let(:invalid_attributes) { { name: "" } }

  describe "GET /index" do
    context "with companies available" do
      let!(:companies) { create_list(:company, 2) }
      let(:expected_body) { index_expected_response(companies) }

      before do
        get api_v1_companies_url, as: :json
      end

      it "renders a successful response" do
        expect(response).to be_successful
      end

      it "renders the correct response body" do
        expect(JSON.parse(response.body)).to match(expected_body)
      end
    end

    context "without companies available" do
      let(:expected_body) { [] }

      before do
        get api_v1_companies_url, as: :json
      end

      it "renders a successful response" do
        expect(response).to be_successful
      end

      it "renders the correct response body" do
        expect(JSON.parse(response.body)).to match(expected_body)
      end
    end
  end

  describe "GET /show" do
    context "with company available" do
      let(:company) { create(:company) }
      let(:expected_body) { company_attributes(company) }

      before do
        get api_v1_company_url(company), as: :json
      end

      it "renders a successful response" do
        expect(response).to be_successful
      end

      it "renders the correct response body" do
        expect(JSON.parse(response.body)).to match(expected_body)
      end
    end

    context "without company available" do
      let(:random_id) { 1 }
      let(:expected_body) { { message: "Record not found" }.stringify_keys }

      before do
        get api_v1_company_url(random_id), as: :json
      end

      it "renders a successful response" do
        expect(response).to have_http_status(:not_found)
      end

      it "renders the correct response body" do
        expect(JSON.parse(response.body)).to match(expected_body)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:action) do
        post api_v1_companies_url, params: { company: valid_attributes }, as: :json
      end

      it "creates a new Company" do
        expect { action }.to change(Company, :count).by(1)
      end

      it "returns the correct status response" do
        action
        expect(response).to have_http_status(:created)
      end

      it "renders a JSON response" do
        action
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it "renders the created company" do
        action
        expect(response.body).to match(a_string_including("A Company Name"))
      end
    end

    context "with invalid parameters" do
      let(:expected_body) { "{\"name\":[\"can't be blank\"]}" }
      let(:action) do
        post api_v1_companies_url, params: { company: invalid_attributes }, as: :json
      end

      it "does not create a new Company" do
        expect { action }.to change(Company, :count).by(0)
      end

      it "returns the correct status response" do
        action
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders a JSON response" do
        action
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it "renders the errors for the new company" do
        action
        expect(response.body).to match(expected_body)
      end
    end
  end
end
