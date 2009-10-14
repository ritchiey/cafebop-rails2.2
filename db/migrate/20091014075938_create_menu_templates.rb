class CreateMenuTemplates < ActiveRecord::Migration
  def self.up
    create_table :menu_templates do |t|
      t.string :name
      t.text :yaml_data
      t.timestamps
    end
  end
  
  def self.down
    drop_table :menu_templates
  end
end
