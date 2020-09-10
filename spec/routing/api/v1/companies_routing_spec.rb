# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CompaniesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/v1/companies").to route_to("api/v1/companies#index")
    end

    it "routes to #show" do
      expect(get: "/api/v1/companies/1").to route_to("api/v1/companies#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/api/v1/companies").to route_to("api/v1/companies#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/companies/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(patch: "/companies/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(delete: "/companies/1").not_to be_routable
    end
  end
end
