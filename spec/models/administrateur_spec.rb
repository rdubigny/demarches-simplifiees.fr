describe Administrateur, type: :model do
  let(:administration) { create(:administration) }

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:instructeurs) }
    it { is_expected.to belong_to(:admins_group).optional }
  end

  describe "#can_be_deleted?" do
    subject { administrateur.can_be_deleted? }

    context "when the administrateur's procedures have other administrateurs" do
      let!(:administrateur) { create(:administrateur) }
      let!(:autre_administrateur) { create(:administrateur) }
      let!(:procedure) { create(:procedure, administrateurs: [administrateur, autre_administrateur]) }

      it { is_expected.to be true }
    end

    context "when the administrateur has a procedure where they is the only admin" do
      let!(:administrateur) { create(:administrateur) }
      let!(:procedure) { create(:procedure, administrateurs: [administrateur]) }

      it { is_expected.to be false }
    end

    context "when the administrateur has no procedure" do
      let!(:administrateur) { create(:administrateur) }

      it { is_expected.to be true }
    end
  end

  describe '#delete_and_transfer_services' do
    let!(:administrateur) { create(:administrateur) }
    let!(:autre_administrateur) { create(:administrateur) }
    let!(:procedure) { create(:procedure, :with_service, administrateurs: [administrateur, autre_administrateur]) }
    let(:service) { procedure.service }

    it "delete and transfer services to other admin" do
      service.update(administrateur: administrateur)
      administrateur.delete_and_transfer_services

      expect(Administrateur.find_by(id: administrateur.id)).to be_nil
      expect(service.reload.administrateur).to eq(autre_administrateur)
    end

    it "delete service if not associated to procedures" do
      service_without_procedure = create(:service, administrateur: administrateur)
      administrateur.delete_and_transfer_services

      expect(Service.find_by(id: service_without_procedure.id)).to be_nil
      expect(Administrateur.find_by(id: administrateur.id)).to be_nil
    end

    it "does not delete service if associated to an archived procedure" do
      service.update(administrateur: administrateur)
      procedure.discard!
      administrateur.delete_and_transfer_services

      expect(Service.find_by(id: procedure.service.id)).not_to be_nil
      expect(Administrateur.find_by(id: administrateur.id)).to be_nil
    end

    context "proedure without service" do
      let!(:procedure) { create(:procedure, :draft, administrateurs: [administrateur, autre_administrateur]) }

      it "delete procedure without service" do
        administrateur.delete_and_transfer_services
        expect(Administrateur.find_by(id: administrateur.id)).to be_nil
      end
    end
  end

  describe '#merge' do
    let(:new_admin) { create(:administrateur) }
    let(:old_admin) { create(:administrateur) }

    subject { new_admin.merge(old_admin) }

    context 'when the old admin does not exist' do
      let(:old_admin) { nil }

      it { expect { subject }.not_to raise_error }
    end

    context 'when the old admin has a procedure' do
      let(:procedure) { create(:procedure) }
      let(:discarded_procedure) { create(:procedure, :discarded) }

      before do
        old_admin.procedures << procedure << discarded_procedure
        subject
        [new_admin, old_admin].map(&:reload)
      end

      it 'transfers the procedure' do
        expect(new_admin.procedures.with_discarded).to match_array([procedure, discarded_procedure])
        expect(old_admin.procedures.with_discarded).to be_empty
      end
    end

    context 'when both admins share a procedure' do
      let(:procedure) { create(:procedure) }

      before do
        new_admin.procedures << procedure
        old_admin.procedures << procedure
        subject
        [new_admin, old_admin].map(&:reload)
      end

      it 'removes the procedure from the old one' do
        expect(old_admin.procedures).to be_empty
      end
    end

    context 'when the old admin has a service' do
      let(:service) { create(:service, administrateur: old_admin) }

      before do
        service
        subject
        [new_admin, old_admin].map(&:reload)
      end

      it 'transfers the service' do
        expect(new_admin.services).to match_array(service)
      end
    end

    context 'when both admins have a service with the same name' do
      let!(:service_1) { create(:service, nom: 'S', administrateur: old_admin) }
      let!(:service_2) { create(:service, nom: 'S', administrateur: new_admin) }
      let!(:procedure_1) { create(:procedure, service: service_1) }

      it 'removes the service from the old one' do
        subject
        [new_admin, old_admin, service_2].map(&:reload)

        expect(old_admin.services).to be_empty
        expect(service_2.procedures).to include(procedure_1)
      end

      context 'and a discarded procedure use this service' do
        let!(:procedure_1) { create(:procedure, :discarded, service: service_1) }
        let!(:procedure_2) { create(:procedure, :discarded, service: service_1) }

        it 'transfers old service to targeted_administrateur' do
          expect { subject }.not_to raise_error
        end
      end
    end

    context 'when the old admin has an instructeur' do
      let(:instructeur) { create(:instructeur) }

      before do
        old_admin.instructeurs << instructeur
        subject
        [new_admin, old_admin].map(&:reload)
      end

      it 'transfers the instructeur' do
        expect(new_admin.instructeurs).to match_array(instructeur)
        expect(old_admin.instructeurs).to be_empty
      end
    end

    context 'when the old admin has an v3 api token' do
      let(:old_admin) { create(:administrateur, :with_api_token) }

      it 'transferts the api token' do
        token = old_admin.api_tokens.first
        subject
        expect(new_admin.api_tokens.count).to eq 1
        expect(new_admin.api_tokens.first).to eq token
      end
    end

    context 'when the old admin has an old api token' do
      let(:old_admin) { create(:administrateur, :with_api_token) }

      it 'does not transfer the api token' do
        old_admin.api_tokens.first.update(version: 2)
        subject
        expect(new_admin.api_tokens.count).to eq 0
      end
    end

    context 'when both admins share an instructeur' do
      let(:instructeur) { create(:instructeur) }

      before do
        old_admin.instructeurs << instructeur
        new_admin.instructeurs << instructeur
        subject
        [new_admin, old_admin].map(&:reload)
      end

      it 'transfers the instructeur' do
        expect(new_admin.instructeurs).to match_array(instructeur)
        expect(old_admin.instructeurs).to be_empty
      end
    end
  end

  describe 'unused' do
    subject { Administrateur.unused }

    let(:new_admin) { create(:administrateur) }
    let(:unused_admin) { create(:administrateur, :with_api_token) }

    before do
      new_admin.user.update(last_sign_in_at: (6.months - 1.day).ago)
      unused_admin.user.update(last_sign_in_at: (6.months + 1.day).ago)
    end

    it { is_expected.to match([unused_admin]) }

    context 'with a hidden procedure' do
      let(:procedure) { create(:procedure, hidden_at: 1.month.ago) }

      before { unused_admin.procedures << procedure }

      it { is_expected.to be_empty }
    end

    context 'with a with_api_token on api v1' do
      before { unused_admin.api_tokens.first.touch(:last_v1_authenticated_at) }

      it { is_expected.to be_empty }
    end

    context 'with a with_api_token on api v2' do
      before { unused_admin.api_tokens.first.touch(:last_v2_authenticated_at) }

      it { is_expected.to be_empty }
    end

    context 'with a service' do
      let(:service) { create(:service) }

      before { unused_admin.services << service }

      it { is_expected.to be_empty }
    end

    context 'with a custom longer threshold period' do
      before { stub_const("Administrateur::UNUSED_ADMIN_THRESHOLD", 7.months) }

      it { is_expected.to be_empty }
    end

    context 'with a custom shorter threshold period' do
      before { stub_const("Administrateur::UNUSED_ADMIN_THRESHOLD", 5.months) }

      it { is_expected.to match_array([new_admin, unused_admin]) }
    end
  end

  describe 'zones' do
    let(:admin) { create(:administrateur) }
    let(:zone1) { create(:zone) }
    let(:zone2) { create(:zone) }
    let!(:procedure) { create(:procedure, administrateurs: [admin], zones: [zone1, zone2]) }

    it 'return zones of procedures that the admin is associated' do
      expect(admin.zones).to eq [zone1, zone2]
    end
  end
end
