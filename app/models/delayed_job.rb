class DelayedJob < ActiveRecord::Base 
  
  fields do
    priority    :integer,    :default => 0
    attempts    :integer,    :default => 0
    handler     :text     
    last_error  :text     
    run_at      :datetime 
    locked_at   :datetime 
    failed_at   :datetime 
    locked_by   :text     
    created_at  :datetime 
    updated_at  :datetime 
  end
end
