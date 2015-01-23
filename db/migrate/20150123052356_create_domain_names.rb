class CreateDomainNames < ActiveRecord::Migration
  def change
    create_table :domain_names do |t|
      t.string :name

      t.timestamps
    end
  end
end
