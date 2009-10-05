
module ActiveRecord
  class Base

    def self.treat_as_currency fields
      fields.kind_of?(Array) || fields = [fields]
      fields.each do |field|
        field = field.to_s

        # Convert price from integer
        define_method "#{field}" do
          Dollars.from_int(self.send("#{field}_in_cents"))
        end

        # Convert price to integer
        define_method("#{field}=") do |in_currency|
          self["#{field}_in_cents"] =  Dollars.to_int(in_currency)
        end
      end
    end
  end
end
