class AddArmStatusToArms < ActiveRecord::Migration
  def change
    add_column :arms, :armstatus, :string,:default=>"nor"

  end
end
