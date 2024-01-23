class AddExpirationNoticesSentAtColumnToAPIToken < ActiveRecord::Migration[7.0]
  def change
    add_column :api_tokens, :expiration_notices_sent, :string, array: true, default: []
  end
end
