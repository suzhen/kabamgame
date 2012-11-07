class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name #城市名称
      t.string :coordinate #城市坐标
      t.integer :pfinterval,:default=>3600 #生产食物间隔（秒)
      t.integer :taxrate,:default=>20 #税率
      t.integer :population,:default=>100 #人口数目
      t.integer :gold,:default=>0 #金子
      t.integer :food,:default=>0 #食物
      t.integer :capital,:default=>false #首都标识
      t.references :user 
      t.timestamps
    end
  end
end
