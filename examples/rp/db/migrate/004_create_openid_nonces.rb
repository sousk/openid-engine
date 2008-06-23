class CreateOpenidNonces < ActiveRecord::Migration
  def self.up
    create_table :openid_nonces do |t|
      t.string :op_endpoint, :nonce
      t.timestamps
    end
  end

  def self.down
    drop_table :openid_nonces
  end
end
