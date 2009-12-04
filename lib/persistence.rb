
class Persistence
  
  attr_accessor :key, :scope, :attrs, :store, :target

  def initialize store, target, options
    @store = store
    @target = target
    target_class = target.class
    @key = options[:key] || target_class.name.underscore
    @scope = scope_for(options[:scope], target)
    @attrs = attrs_for(options[:attrs], target)
  end

  def self.persist_to store, target, options={}
    Persistence.new(store, target, options).persist
  end
  
  def self.restore_from store, target, options={}
    Persistence.new(store, target, options).restore
  end
  
  def persist
    entry[@scope.to_s] ||= {}
    @attrs.each {|attr| entry[@scope.to_s][attr.to_sym] = @target.send(attr.to_s)}
  end
  
  def entry
    store[@key.to_sym] ||= {}
  end
    
  def restore
    if entry[@scope.to_s]
      @attrs.each {|key| target.send("#{key.to_s}=", entry[@scope.to_s][key.to_sym])}
    end
  end

private

  def scope_for specified, target
    (specified == :class and target.class.name.underscore) ||
    (specified == :global and :global) ||
    (specified and target.respond_to?(specified) and (target.send(specified) or '_nil')) ||
    (target.respond_to?(:persistent_scope) and target.persistent_scope) ||
    (target.respond_to?(:id) and (target.id or '_nil')) ||
    :global
  end

  def attrs_for specified, target
    specified ||
    (target.respond_to?(:persistent_attrs) and target.persistent_attrs) ||
    (target.respond_to?(:attribute_names) and target.attribute_names) ||
    []
  end            
  

end