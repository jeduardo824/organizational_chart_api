# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collaborator, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:company) }

  describe "email validations" do
    it { is_expected.to allow_value("example@example.com").for(:email) }
    it { is_expected.not_to allow_value("invalid email").for(:email) }

    context "using the same email" do
      before do
        create(:collaborator, email: "example@example.com")
      end

      it { is_expected.not_to allow_value("example@example.com").for(:email) }
    end

    context "using the same email with capitalized letters" do
      before do
        create(:collaborator, email: "ExAMplE@example.com")
      end

      it { is_expected.not_to allow_value("example@example.com").for(:email) }
    end
  end
end
