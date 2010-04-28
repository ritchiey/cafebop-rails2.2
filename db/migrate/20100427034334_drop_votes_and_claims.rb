class DropVotesAndClaims < ActiveRecord::Migration
  def self.up
    drop_table :votes
    drop_table :claims
    
    remove_column :shops, :votes_count
  end

  def self.down
    add_column :shops, :votes_count, :integer, :default => 0
    
    create_table "votes", :force => true do |t|
      t.string   "email"
      t.boolean  "notification_requested"
      t.boolean  "confirmed"
      t.string   "confirmation_key"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "shop_id"
      t.integer  "user_id"
    end
    
    create_table "claims", :force => true do |t|
      t.text     "notes"
      t.string   "state",       :default => "pending"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.integer  "shop_id"
      t.integer  "reviewer_id"
      t.string   "first_name"
      t.string   "last_name"
    end
  end
end
