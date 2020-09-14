# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/collaborators", type: :request do
  include CollaboratorsSpecHelper

  let(:name) { "Collaborator name" }
  let(:email) { "collaborator@email.com" }
  let(:company) { create(:company) }

  let(:valid_attributes) {
    {
      name: name,
      email: email
    }
  }

  describe "GET /index" do
    context "with several companies available" do
      let!(:collaborators) { create_list(:collaborator, 2, company: company) }
      let(:expected_body) { index_expected_response(collaborators) }

      before do
        create_list(:collaborator, 5)
        get api_v1_company_collaborators_url(company.id), as: :json
      end

      it "renders a successful response" do
        expect(response).to be_successful
      end

      it "renders the collaborators of the given company" do
        expect(JSON.parse(response.body)).to match(expected_body)
      end
    end

    context "without collaborators on the company" do
      let(:expected_body) { [] }

      before do
        create_list(:collaborator, 5)
        get api_v1_company_collaborators_url(company.id), as: :json
      end

      it "renders a successful response" do
        expect(response).to be_successful
      end

      it "renders the correct response body" do
        expect(JSON.parse(response.body)).to match(expected_body)
      end
    end

    context "with invalid company" do
      let(:company_id) { 1 }
      let(:expected_body) { { "message" => "Record not found" } }

      before do
        create_list(:collaborator, 5)
        get api_v1_company_collaborators_url(company_id), as: :json
      end

      it "returns the correct status code" do
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
        post api_v1_company_collaborators_url(company.id),
             params: { collaborator: valid_attributes }, as: :json
      end

      it "creates a new Collaborator" do
        expect { action }.to change(Collaborator, :count).by(1)
      end

      it "returns the correct status code" do
        action
        expect(response).to have_http_status(:created)
      end

      it "renders a JSON response" do
        action
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it "renders the created collaborator" do
        action
        expect(response.body).to match(a_string_including("Collaborator name")) & \
                                 match(a_string_including("collaborator@email.com")) & \
                                 match(a_string_including(company.id))
      end
    end

    context "with invalid parameters" do
      let(:action) do
        post api_v1_company_collaborators_url(company_id),
             params: { collaborator: invalid_attributes }, as: :json
      end

      context "invalid email" do
        let(:expected_body) { "{\"email\":[\"is invalid\"]}" }
        let(:invalid_attributes) {
          {
            name: name,
            email: "invalid email"
          }
        }
        let(:company_id) { create(:company).id }

        it "does not create a new Collaborator" do
          expect { action }.to change(Collaborator, :count).by(0)
        end

        it "returns the correct status code" do
          action
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders a JSON response" do
          action
          expect(response.content_type).to match(a_string_including("application/json"))
        end

        it "renders the error for the collaborator" do
          action
          expect(response.body).to match(expected_body)
        end
      end

      context "existing email" do
        let(:expected_body) { "{\"email\":[\"has already been taken\"]}" }
        let(:invalid_attributes) {
          {
            name: name,
            email: email
          }
        }
        let(:company_id) { create(:company).id }

        before do
          create(:collaborator, email: email)
        end

        it "does not create a new Collaborator" do
          expect { action }.to change(Collaborator, :count).by(0)
        end

        it "returns the correct status code" do
          action
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders a JSON response" do
          action
          expect(response.content_type).to match(a_string_including("application/json"))
        end

        it "renders the error for the collaborator" do
          action
          expect(response.body).to match(expected_body)
        end
      end

      context "blank name" do
        let(:expected_body) { "{\"name\":[\"can't be blank\"]}" }
        let(:invalid_attributes) {
          {
            name: "",
            email: email
          }
        }
        let(:company_id) { create(:company).id }

        it "does not create a new Collaborator" do
          expect { action }.to change(Collaborator, :count).by(0)
        end

        it "returns the correct status code" do
          action
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders a JSON response" do
          action
          expect(response.content_type).to match(a_string_including("application/json"))
        end

        it "renders the error for the collaborator" do
          action
          expect(response.body).to match(expected_body)
        end
      end

      context "invalid company" do
        let(:expected_body) { "{\"message\":\"Record not found\"}" }
        let(:invalid_attributes) {
          {
            name: name,
            email: email
          }
        }
        let(:company_id) { 1 }

        it "does not create a new Collaborator" do
          expect { action }.to change(Collaborator, :count).by(0)
        end

        it "returns the correct status code" do
          action
          expect(response).to have_http_status(:not_found)
        end

        it "renders a JSON response" do
          action
          expect(response.content_type).to match(a_string_including("application/json"))
        end

        it "renders the error for the not existing company" do
          action
          expect(response.body).to match(expected_body)
  describe "PUT /update" do
    let(:company) { create(:company) }
    let!(:collaborator) { create(:collaborator, company: company) }
    let!(:manager) { create(:collaborator, company: company) }

    context "valid request" do
      let(:expected_body) { collaborator_attributes(collaborator) }

      before do
        put api_v1_collaborator_url(collaborator),
            params: { manager_id: manager.id },
            as: :json

        collaborator.reload
      end

      it "returns the correct status code" do
        expect(response).to have_http_status(:ok)
      end

      it "saves the manager correctly" do
        expect(collaborator.manager).to eq(manager)
      end

      it "renders the updated collaborator" do
        expect(JSON.parse(response.body)).to match(expected_body)
      end
    end

    context "invalid request" do
      context "when collaborator already has manager" do
        let(:original_manager) { create(:collaborator, company: company) }
        let(:expected_body) { exception_body("Collaborator already has manager") }

        let!(:collaborator) do
          create(:collaborator, company: company, manager: original_manager)
        end

        before do
          put api_v1_collaborator_url(collaborator),
              params: { manager_id: manager.id },
              as: :json

          collaborator.reload
        end

        it "returns the correct status code" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not save the new manager" do
          expect(collaborator.manager).to eq(original_manager)
        end

        it "renders the error message" do
          expect(JSON.parse(response.body)).to eq(expected_body)
        end
      end

      context "when manager is not in the same company" do
        let(:manager) { create(:collaborator) }
        let(:expected_body) do
          exception_body("The manager is not in the same company of the collaborator")
        end

        before do
          put api_v1_collaborator_url(collaborator),
              params: { manager_id: manager.id },
              as: :json

          collaborator.reload
        end

        it "returns the correct status code" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not save the new manager" do
          expect(collaborator.manager).to eq(nil)
        end

        it "renders the error message" do
          expect(JSON.parse(response.body)).to eq(expected_body)
        end
      end

      context "when manager is below in the hierarchy" do
        let(:other_collaborator) { create(:collaborator, company: company) }
        let(:expected_body) do
          exception_body("The manager is below the collaborator in the hierarchy")
        end

        before do
          manager.update!(manager: other_collaborator)
          other_collaborator.update!(manager: collaborator)

          put api_v1_collaborator_url(collaborator),
              params: { manager_id: manager.id },
              as: :json

          collaborator.reload
        end

        it "returns the correct status code" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not save the new manager" do
          expect(collaborator.manager).to eq(nil)
        end

        it "renders the error message" do
          expect(JSON.parse(response.body)).to eq(expected_body)
        end
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:collaborator) { create(:collaborator) }
    let(:action) { delete api_v1_collaborator_url(collaborator), as: :json }

    it "destroys the requested collaborator" do
      expect { action }.to change(Collaborator, :count).by(-1)
    end

    it "returns the correct status code" do
     action
     expect(response).to have_http_status(:no_content)
   end
  end
end
