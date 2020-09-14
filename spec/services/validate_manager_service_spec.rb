# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidateManagerService, type: :service do
  describe ".call!" do
    let(:company) { create(:company) }
    let(:collaborator) { create(:collaborator, company: company) }
    let(:manager) { create(:collaborator, company: company) }
    let(:status) { :unprocessable_entity }

    context "when collaborator already has a manager" do
      let(:original_manager) { create(:collaborator, company: company) }
      let(:error_message) { "Collaborator already has manager" }

      let(:collaborator) do
        create(:collaborator, company: company, manager: original_manager)
      end

      let(:error_attributes) do
        { message: error_message, status:  status }
      end

      subject do
        described_class.call!(collaborator: collaborator, manager: manager)
      end

      it "throws an exception with correct attributes" do
        expect { subject }.
          to raise_error(an_instance_of(InvalidRequest).
                         and having_attributes(error_attributes))
      end
    end

    context "when manager is not in the same company" do
      let(:manager) { create(:collaborator) }

      let(:error_message) do
        "The manager is not in the same company of the collaborator"
      end

      let(:error_attributes) do
        { message: error_message, status:  status }
      end

      subject do
        described_class.call!(collaborator: collaborator, manager: manager)
      end

      it "throws an exception with correct attributes" do
        expect { subject }.
          to raise_error(an_instance_of(InvalidRequest).
                         and having_attributes(error_attributes))
      end
    end

    context "when manager is below in the hierarchy" do
      let(:other_collaborator) { create(:collaborator, company: company) }

      let(:error_message) do
        "The manager is below the collaborator in the hierarchy"
      end

      let(:error_attributes) do
        { message: error_message, status:  status }
      end

      before do
        manager.update!(manager: other_collaborator)
        other_collaborator.update!(manager: collaborator)
      end

      subject do
        described_class.call!(collaborator: collaborator, manager: manager)
      end

      it "throws an exception with correct attributes" do
        expect { subject }.
          to raise_error(an_instance_of(InvalidRequest).
                         and having_attributes(error_attributes))
      end
    end

    context "when manager can manage the collaborator" do
      subject do
        described_class.call!(collaborator: collaborator, manager: manager)
      end

      it "does not throws an exception" do
        expect { subject }.not_to raise_error
      end
    end
  end
end
