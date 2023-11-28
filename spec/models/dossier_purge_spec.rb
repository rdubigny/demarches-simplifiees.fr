describe Dossier, type: :model do
  describe '.purge_discarded' do
    it 'discards brouillon, en_construction and termine' do
      [
        :en_brouillon_expired_to_delete,
        :en_construction_expired_to_delete,
        :termine_expired_to_delete
      ].each do |scope|
        dossier = double(purge_discarded: true)
        expect(dossier).to receive(:purge_discarded)

        collection = double(find_each: true)
        expect(collection).to receive(:find_each) { |&block| block.call(dossier) }

        expect(Dossier).to receive(scope).and_return(collection)
      end

      Dossier.purge_discarded
    end
  end
end
