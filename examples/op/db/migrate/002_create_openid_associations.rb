class CreateOpenidAssociations < ActiveRecord::Migration
  def self.up
    create_table :openid_associations do |t|
      t.string :handle, :encryption_type
      t.integer :lifetime
      t.binary :secret

      t.timestamps
    end
  end

  def self.down
    drop_table :openid_associations
  end
end
