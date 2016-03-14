require 'rails_helper'

describe Gestionnaire, type: :model do
  describe 'database column' do
    it { is_expected.to have_db_column(:email) }
    it { is_expected.to have_db_column(:encrypted_password) }
    it { is_expected.to have_db_column(:reset_password_token) }
    it { is_expected.to have_db_column(:reset_password_sent_at) }
    it { is_expected.to have_db_column(:remember_created_at) }
    it { is_expected.to have_db_column(:sign_in_count) }
    it { is_expected.to have_db_column(:current_sign_in_at) }
    it { is_expected.to have_db_column(:last_sign_in_at) }
    it { is_expected.to have_db_column(:current_sign_in_ip) }
    it { is_expected.to have_db_column(:last_sign_in_ip) }
    it { is_expected.to have_db_column(:created_at) }
    it { is_expected.to have_db_column(:updated_at) }
  end

  describe 'association' do
    it { is_expected.to belong_to(:administrateur) }
    it { is_expected.to have_many(:procedures) }
    it { is_expected.to have_many(:dossiers) }
  end

  describe '#dossiers_filter' do
    let(:admin) { create :administrateur }
    let(:procedure) { create :procedure, administrateur: admin }
    let(:procedure_2) { create :procedure, administrateur: admin }
    let(:gestionnaire) { create :gestionnaire, procedure_filter: procedure_filter, administrateur: admin }
    let!(:dossier) { create :dossier, procedure: procedure }
    let(:procedure_filter) { [] }

    subject { gestionnaire.dossiers_filter }

    context 'before filter' do
      it { expect(subject.size).to eq 1 }
    end

    context 'after filter' do
      let(:procedure_filter) { [procedure_2.id] }

      it { expect(subject.size).to eq 0 }
    end
  end

  describe '#procedure_filter_list' do
    let(:admin) { create :administrateur }
    let!(:procedure) { create :procedure, administrateur: admin }
    let!(:procedure_2) { create :procedure, administrateur: admin }
    let(:gestionnaire) { create :gestionnaire, procedure_filter: procedure_filter, administrateur: admin }

    let(:procedure_filter) { [] }

    subject { gestionnaire.procedure_filter_list }

    context 'when gestionnaire procedure_filter is empty' do
      it { expect(subject).to eq [procedure.id, procedure_2.id] }
    end

    context 'when gestionnaire procedure_filter is no empty' do
      let(:procedure_filter) { [procedure.id] }

      it { expect(subject).to eq [procedure.id] }
    end
  end
end
