class Shop < ActiveRecord::Base
  
  fields do
    name    :string
    phone   :string
    fax     :string
    website :string    
    email_address :email_address
    timestamps
  end                           
  

end
