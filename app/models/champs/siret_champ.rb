# == Schema Information
#
# Table name: champs
#
#  id                             :integer          not null, primary key
#  data                           :jsonb
#  external_data_exceptions       :jsonb
#  fetch_external_data_exceptions :string           is an Array
#  prefilled                      :boolean          default(FALSE)
#  private                        :boolean          default(FALSE), not null
#  rebased_at                     :datetime
#  type                           :string
#  value                          :string
#  value_json                     :jsonb
#  created_at                     :datetime
#  updated_at                     :datetime
#  dossier_id                     :integer
#  etablissement_id               :integer
#  external_id                    :string
#  parent_id                      :bigint
#  row_id                         :string
#  type_de_champ_id               :integer
#
class Champs::SiretChamp < Champ
  include SiretChampEtablissementFetchableConcern

  after_validation :update_external_id

  def search_terms
    etablissement.present? ? etablissement.search_terms : [value]
  end

  def mandatory_blank?
    mandatory? && Siret.new(siret: value).invalid?
  end

  def fetchable_external_data?
    true
  end

  def pollable_external_data?
    true
  end

  def fetch_external_data
    fetch_etablissement!(external_id, dossier.user)
  end

  def update_external_id
    if value.present?
      self.external_id = value
      #self.etablissement = nil
    end
  end
end
