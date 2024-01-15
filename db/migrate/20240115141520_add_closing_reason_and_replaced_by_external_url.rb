class AddClosingReasonAndReplacedByExternalURL < ActiveRecord::Migration[7.0]
  def change
    add_column :procedures, :closing_reason, :string
    add_column :procedures, :replaced_by_external_url, :string
  end
end
