class CreateDomainNames < ActiveRecord::Migration
  def change
    create_table :domain_names do |t|
      t.string :domain_name

      t.timestamps
    end
  end
end
