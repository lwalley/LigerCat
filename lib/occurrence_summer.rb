class OccurrenceSummer
  attr_reader :occurrences
  
  def initialize(key_method = :to_s)
    @method = key_method.to_sym
    @occurrences = Hash.new(0)
  end
  
  def sum(items)
    if items.is_a? Array
      sum_many(items)
    else
      sum_one(items)
    end
    return self
  end
  
  
  private
  
  def sum_one(item)
    k = item.send(@method)
    @occurrences[k] = @occurrences[k] + 1
  end
  
  def sum_many(items)
    items.each{ |item| sum_one(item) }
  end
end