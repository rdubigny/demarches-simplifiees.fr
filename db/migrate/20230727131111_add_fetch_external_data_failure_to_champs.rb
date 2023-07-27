class AddFetchExternalDataFailureToChamps < ActiveRecord::Migration[7.0]
  def change
    add_column :champs, :external_data_exceptions, :jsonb
  end
end
