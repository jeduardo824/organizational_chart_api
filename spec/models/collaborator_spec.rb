# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collaborator, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:company) }

  it do
    is_expected.to have_many(:managed).
                   class_name("Collaborator").
                   dependent(:nullify).
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

    context "when collaborator has manager" do
      let(:collaborators) do
        create_list(:collaborator, 3, manager: manager, company: manager.company)
      end

      subject { collaborators.first.peers }

      it "returns the correct peers" do
        expect(subject).to match([collaborators.second, collaborators.third])
      end
    end

    context "when collaborator has not manager" do
      let(:collaborator) { create(:collaborator, manager: nil) }

      subject { collaborator.peers }

      it "returns the correct peers" do
        expect(subject).to eq([])
      end
    end

    context "when collaborator has manager without other managed" do
      let(:collaborator) { create(:collaborator, manager: manager) }

      subject { collaborator.peers }

      it "returns the correct peers" do
        expect(subject).to eq([])
      end
    end
  end
end
