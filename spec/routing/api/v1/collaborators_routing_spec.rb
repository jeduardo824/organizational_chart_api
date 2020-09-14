# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CollaboratorsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/v1/companies/1/collaborators").to route_to("api/v1/collaborators#index", company_id: "1")
    end

    it "routes to #show" do
      expect(get: "/api/v1/collaborators/1").to route_to("api/v1/collaborators#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/api/v1/companies/1/collaborators").to route_to("api/v1/collaborators#create", company_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/api/v1/collaborators/1").to route_to("api/v1/collaborators#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/api/v1/collaborators/1").to route_to("api/v1/collaborators#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/api/v1/collaborators/1").to route_to("api/v1/collaborators#destroy", id: "1")
    end
  end
end
