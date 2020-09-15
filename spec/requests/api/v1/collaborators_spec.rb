# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/collaborators", type: :request do
  include CollaboratorsSpecHelper
  include RequestExceptionSpecHelper

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
      let(:expected_body) { collaborators_expected_response(collaborators) }

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
      before do
        create_list(:collaborator, 5)
        get api_v1_company_collaborators_url(company.id), as: :json
      end

      it "renders a successful response" do
        expect(response).to be_successful
      end

      it "renders the correct response body" do
        expect(JSON.parse(response.body)).to match([])
      end
    end

    context "with invalid company" do
      let(:company_id) { 1 }
      let(:expected_body) do
        exception_body("Couldn't find Company with 'id'=#{company_id}")
      end

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
        let(:expected_body) { exception_body("Validation failed: Email is invalid") }
        let(:company_id) { create(:company).id }
        let(:invalid_attributes) do
          {
            name: name,
            email: "invalid email"
          }
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
          expect(JSON.parse(response.body)).to match(expected_body)
        end
      end

      context "existing email" do
        let(:company_id) { create(:company).id }
        let(:invalid_attributes) do
          {
            name: name,
            email: email
          }
        end

        let(:expected_body) do
          exception_body("Validation failed: Email has already been taken")
        end

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
          expect(JSON.parse(response.body)).to match(expected_body)
        end
      end

      context "blank name" do
        let(:expected_body) { exception_body("Validation failed: Name can't be blank") }
        let(:company_id) { create(:company).id }
        let(:invalid_attributes) do
          {
            name: "",
            email: email
          }
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
          expect(JSON.parse(response.body)).to match(expected_body)
        end
      end

      context "invalid company" do
        let(:company_id) { 1 }

        let(:expected_body) do
          exception_body("Couldn't find Company with 'id'=#{company_id}")
        end

        let(:invalid_attributes) do
          {
            name: name,
            email: email
          }
        end

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
          expect(JSON.parse(response.body)).to match(expected_body)
        end
      end
    end
  end

  describe "GET /show" do
    let(:company) { create(:company) }
    let(:manager) { create(:collaborator, company: company) }
    let!(:collaborators) do
      create_list(:collaborator, 3, manager: manager, company: company)
    end

    context "valid request" do
      context "with peers as info_type" do
        context "with collaborators available" do
          let(:info_type) { :peers }
          let(:expected_body) do
            collaborators_expected_response([collaborators.second, collaborators.third])
          end

          before do
            get api_v1_collaborator_url(id: collaborators.first.id,
                                        info_type: info_type), as: :json
          end

          it "returns the correct status code" do
            expect(response).to have_http_status(:ok)
          end

          it "renders the correct records" do
            expect(JSON.parse(response.body)).to match(expected_body)
          end
        end

        context "without collaborators available" do
          let(:info_type) { :peers }
          let(:other_manager) { create(:collaborator, company: company) }
          let(:collaborator) do
            create(:collaborator, company: company, manager: other_manager)
          end

          before do
            get api_v1_collaborator_url(id: collaborator.id,
                                        info_type: info_type), as: :json
          end

          it "returns the correct status code" do
            expect(response).to have_http_status(:ok)
          end

          it "renders the correct records" do
            expect(JSON.parse(response.body)).to match([])
          end
        end
      end

      context "with managed as info_type" do
        context "with collaborators available" do
          let(:info_type) { :managed }
          let(:expected_body) do
            collaborators_expected_response(collaborators)
          end

          before do
            get api_v1_collaborator_url(id: manager,
                                        info_type: info_type), as: :json
          end

          it "returns the correct status code" do
            expect(response).to have_http_status(:ok)
          end

          it "renders the correct records" do
            expect(JSON.parse(response.body)).to match(expected_body)
          end
        end

        context "without collaborators available" do
          let(:info_type) { :managed }
          let(:other_manager) { create(:collaborator, company: company) }

          before do
            get api_v1_collaborator_url(id: other_manager,
                                        info_type: info_type), as: :json
          end

          it "returns the correct status code" do
            expect(response).to have_http_status(:ok)
          end

          it "renders the correct records" do
            expect(JSON.parse(response.body)).to match([])
          end
        end
      end

      context "with second_level_managed as info_type" do
        context "with collaborators available" do
          let(:info_type) { :second_level_managed }

          let!(:first_collab_managed) do
            create_list(:collaborator, 2,
                        company: company,
                        manager: collaborators.first)
          end

          let!(:second_collab_managed) do
            create_list(:collaborator, 5,
                        company: company,
                        manager: collaborators.second)
          end

          let(:expected_body) do
            collaborators_expected_response([first_collab_managed, second_collab_managed].flatten)
          end

          before do
            get api_v1_collaborator_url(id: manager,
                                        info_type: info_type), as: :json
          end

          it "returns the correct status code" do
            expect(response).to have_http_status(:ok)
          end

          it "renders the correct records" do
            expect(JSON.parse(response.body)).to match(expected_body)
          end
        end

        context "without collaborators available" do
          let(:info_type) { :second_level_managed }

          before do
            get api_v1_collaborator_url(id: manager,
                                        info_type: info_type), as: :json
          end

          it "returns the correct status code" do
            expect(response).to have_http_status(:ok)
          end

          it "renders the correct records" do
            expect(JSON.parse(response.body)).to match([])
          end
        end
      end
    end

    context "invalid request" do
      context "with invalid info_type" do
        let(:info_type) { :invalid }
        let(:expected_body) { exception_body("Information type is not valid") }

        before do
          get api_v1_collaborator_url(id: manager,
                                      info_type: info_type), as: :json
        end

        it "returns the correct status code" do
          expect(response).to have_http_status(:bad_request)
        end

        it "renders the correct records" do
          expect(JSON.parse(response.body)).to match(expected_body)
        end
      end

      context "when collaborator does not exist" do
        let(:collaborator_id) { 1 }
        let(:expected_body) do
          exception_body("Couldn't find Collaborator with 'id'=#{collaborator_id}")
        end

        before do
          get api_v1_collaborator_url(id: collaborator_id,
                                      info_type: :peers), as: :json
        end

        it "returns the correct status code" do
          expect(response).to have_http_status(:not_found)
        end

        it "renders the error message" do
          expect(JSON.parse(response.body)).to eq(expected_body)
        end
      end
    end
  end

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

      context "when collaborator does not exist" do
        let(:collaborator_id) { 1 }
        let(:expected_body) do
          exception_body("Couldn't find Collaborator with 'id'=#{collaborator_id}")
        end

        before do
          put api_v1_collaborator_url(collaborator_id),
              params: { manager_id: manager.id },
              as: :json

          collaborator.reload
        end

        it "returns the correct status code" do
          expect(response).to have_http_status(:not_found)
        end

        it "renders the error message" do
          expect(JSON.parse(response.body)).to eq(expected_body)
        end
      end

      context "when manager does not exist" do
        let(:manager_id) { 2 }
        let(:expected_body) do
          exception_body("Couldn't find Collaborator with 'id'=#{manager_id}")
        end

        before do
          put api_v1_collaborator_url(collaborator),
              params: { manager_id: manager_id },
              as: :json

          collaborator.reload
        end

        it "returns the correct status code" do
          expect(response).to have_http_status(:not_found)
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
    let(:action) { delete api_v1_collaborator_url(collaborator), as: :json }

    context "valid request" do
      let!(:collaborator) { create(:collaborator) }
      let(:expected_body) { collaborator_attributes(collaborator) }

      it "destroys the requested collaborator" do
        expect { action }.to change(Collaborator, :count).by(-1)
      end

      it "returns the correct status code" do
        action
        expect(response).to have_http_status(:ok)
      end

      it "returns the deleted collaborator" do
        action
        expect(JSON.parse(response.body)).to match(expected_body)
      end
    end

    context "invalid request" do
      let!(:collaborator) { 1 }
      let(:expected_body) do
        exception_body("Couldn't find Collaborator with 'id'=#{collaborator}")
      end

      it "destroys the requested collaborator" do
        expect { action }.to change(Collaborator, :count).by(0)
      end

      it "returns the correct status code" do
        action
        expect(response).to have_http_status(:not_found)
      end

      it "returns the deleted collaborator" do
        action
        expect(JSON.parse(response.body)).to match(expected_body)
      end
    end
  end
end
