class TAndC < ActiveRecord::Base



  fields do
    timestamps  
    body  :text
    published :boolean
  end


  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    false
  end

  def view_permitted?(field)
    published || acting_user.administrator?
  end

end
