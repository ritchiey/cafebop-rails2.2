
class Currency < Integer

  def to_s
    cents = self || 0
    "%0.2f" % (cents / 100.0)
  end

  def self.from_s(dollars)
    dollars.to_f * 100
  end

end
