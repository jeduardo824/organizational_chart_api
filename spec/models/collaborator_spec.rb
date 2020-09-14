# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collaborator, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:company) }

  it do
    is_expected.to have_many(:managed).
                   class_name("Collaborator").
                   with_foreign_key("manager_id")
  end

  it do
    is_expected.to belong_to(:manager).
                   class_name("Collaborator").
                   optional
  end

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

  describe "#peers" do
    let(:manager) { create(:collaborator) }
    let(:collaborators) do
      create_list(:collaborator, 3, manager: manager, company: manager.company)
    end

    subject { collaborators.first.peers }

    it "returns the correct peers" do
      expect(subject).to match([collaborators.second, collaborators.third])
    end
  end

  describe "#managed_by_manager" do
    let(:manager) { create(:collaborator) }

    let(:collaborators) do
      create_list(:collaborator, 3, manager: manager, company: manager.company)
    end

    let(:expected_array) do
      [collaborators.first, collaborators.second, collaborators.third]
    end

    subject { collaborators.first.managed_by_manager }

    it "returns the correct peers" do
      expect(subject).to match(expected_array)
    end
  end
end
