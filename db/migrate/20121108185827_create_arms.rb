class CreateArms < ActiveRecord::Migration
  def change
    create_table :arms do |t|
      t.string :armtype
      t.integer :num
      t.references :user 
      t.references :city

      t.timestamps
    end
  end
end
