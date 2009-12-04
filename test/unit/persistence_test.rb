require 'test_helper'

class PersistenceTest < ActiveSupport::TestCase
  
  class Target
    attr_accessor :id, :name, :phone, :email, :secret

    def self.dummy_id
      10
    end

    def self.dummy_values
      { 'id'=>Target.dummy_id,
        'name'=>'Hagrid',
        'phone'=>'2222222',
        'email'=>'hagrid@hogwarts.edu',
        'secret'=>"philosopher's stone"
      }
    end
    
    def self.dummy
      self.new(dummy_values)
    end
    
    def initialize attrs={}
      self.attributes = attrs
    end
    
    def ==(other)
      self.attributes == other.attributes
    end
    
    def attributes=(attrs)
      attrs.each { |k, v| self.send("#{k.to_s}=", v)}
    end
    
    def attributes
      {}.tap do |attrs|
        Target.all_value_names.each {|name| v=self.send(name.to_s); attrs[name] = v if v}
      end
    end
    
    def self.all_value_names() %w/id name phone email secret/ end
  end
  
  def setup
    @store = {}
  end
  
  
  def test_target
    empty = Target.new
    assert_equal({}, empty.attributes)
    empty.attributes = Target.dummy_values
    assert_equal Target.dummy_values['name'], empty.name
    assert_equal Target.dummy_values, empty.attributes
    other = Target.dummy
    assert_equal Target.dummy_values, other.attributes
  end
  
  
  def test_persist_retrieve
    target = Target.dummy
    Persistence.persist_to @store, target, :scope=>:global, :attrs=>Target.all_value_names
    retrieved = Target.new
    assert_not_equal target, retrieved
    Persistence.restore_from @store, retrieved, :scope=>:global, :attrs=>Target.all_value_names
    assert_equal target, retrieved
  end            
  
  def test_scope_by_default_with_id
    target = Target.dummy
    Persistence.persist_to @store, target, :scope=>:id, :attrs=>Target.all_value_names
    assert_equal Target.dummy_id, target.id
    assert_equal Target.dummy_id, target.send(:id)
    assert_not_nil @store[:"persistence_test/target"]
    assert_not_nil @store[:"persistence_test/target"][Target.dummy_id.to_s]
    assert_equal @store[:"persistence_test/target"][Target.dummy_id.to_s][:name], target.name
    no_id = Target.new
    Persistence.restore_from @store, no_id, :scope=>:id, :attrs=>Target.all_value_names
    assert_not_equal target, no_id
    wrong_id = Target.new(:id=>Target.dummy_id+1)
    Persistence.restore_from @store, wrong_id, :scope=>:id, :attrs=>Target.all_value_names
    assert_not_equal target, wrong_id
    right_id = Target.new(:id=>Target.dummy_id)
    Persistence.restore_from @store, right_id, :scope=>:id, :attrs=>Target.all_value_names
    assert_equal target, right_id
  end
  
end