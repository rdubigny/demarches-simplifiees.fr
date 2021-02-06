class ApiEntreprise::BilansBdfJob < ApiEntreprise::Job
  def perform(etablissement_id, procedure_id)
    find_etablissement(etablissement_id)
    etablissement_params = ApiEntreprise::BilansBdfAdapter.new(etablissement.siret, procedure_id).to_params
    etablissement.update!(etablissement_params)
  end
end
