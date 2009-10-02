
module ActiveRecord
  class Base

    def self.treat_as_currency fields
      fields.kind_of?(Array) || fields = [fields]
      fields.each do |field|
        field = field.to_s

        # Convert price from integer
        define_method "#{field}_as_currency" do
          Dollars.from_int(self.send(field))
        end

        # Convert price to integer for display
        define_method("#{field}_as_currency=") do |in_currency|
          self[field] =  Dollars.to_int(in_currency)
        end
      end
    end
  end
end
