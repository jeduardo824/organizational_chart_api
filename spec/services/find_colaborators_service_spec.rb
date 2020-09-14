# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindCollaboratorsService, type: :service do
  describe ".call!" do
    let(:company) { create(:company) }
    let(:manager) { create(:collaborator, company: company) }

    context "finding peers" do
      let(:collaborators) do
        create_list(:collaborator, 3, manager: manager, company: company)
      end

      subject do
        described_class.call!(collaborator: collaborators.first,
                             info_type: :peers)
      end

      before do
        # random data to ensure test assertability
        create_list(:collaborator, 2,
                    company: company,
                    manager: collaborators.first)
      end

      it "returns the correct peers" do
        expect(subject).to match([collaborators.second, collaborators.third])
      end
    end

    context "finding managed collaborators" do
      let(:collaborators) do
        create_list(:collaborator, 3, manager: manager, company: company)
      end

      subject do
        described_class.call!(collaborator: manager,
                             info_type: :managed)
      end

      before do
        # random data to ensure test assertability
        create_list(:collaborator, 2,
                    company: company,
                    manager: collaborators.first)
      end

      it "returns the correct managed collaborators" do
        expect(subject).to match(collaborators)
      end
    end

    context "finding second level managed collaborators" do
      let(:collaborators) do
        create_list(:collaborator, 3, manager: manager, company: company)
      end

      let(:first_collab_managed) do
        create_list(:collaborator, 2,
                    company: company,
                    manager: collaborators.first)
      end

      let(:second_collab_managed) do
        create_list(:collaborator, 5,
                    company: company,
                    manager: collaborators.second)
      end

      let(:expected_array) { [first_collab_managed, second_collab_managed].flatten }

      subject do
        described_class.call!(collaborator: manager,
                             info_type: :second_level_managed)
      end

      before do
        # random data to ensure test assertability
        manager.update!(manager: create(:collaborator, company: company))

        create_list(:collaborator, 4,
                    company: company,
                    manager: first_collab_managed.first)

        create_list(:collaborator, 1,
                    company: company,
                    manager: second_collab_managed.first)
      end

      it "returns the correct managed collaborators" do
        expect(subject).to match(expected_array)
      end
    end

    context "with wrong information type" do
      let(:info_type) { :invalid_type }
      let(:status) { :bad_request }

      let(:error_message) do
        "Information type is not valid"
      end

      let(:error_attributes) do
        { message: error_message, status:  status }
      end

      subject do
        described_class.call!(collaborator: manager,
                             info_type: info_type)
      end

      it "throws an exception with correct attributes" do
        expect { subject }.
          to raise_error(an_instance_of(InvalidRequest).
                         and having_attributes(error_attributes))
      end
    end
  end
end
