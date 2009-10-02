
# A type of currency. Stores itself as an integer. Displays
# as a fixed decimal
class Dollars

  def self.to_int(dollars)
    dollars.to_f * 100
  end

  def self.from_int(cents)
    cents ||= 0
    "%0.2f" % (cents.to_i / 100.0)
  end

end
