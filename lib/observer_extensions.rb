class ActiveRecord::Observer
  def logger
    RAILS_DEFAULT_LOGGER
  end
end