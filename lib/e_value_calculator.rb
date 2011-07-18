require 'occurrence_summer'

class EValueCalculator
  attr_accessor :threshold
  attr_reader   :id_freqs, :freq_occ, :sum_freq_occ, :sum_occ
  
  def initialize(id_freqs, threshold)
    raise ArgumentError, "First argument must be a hash of the form { some_identifier => frequency }" unless valid_id_freqs?(id_freqs)
    @id_freqs  = id_freqs  
    @threshold = threshold
  end
  
  # yeilds to the block if e_value is less than the threshold
  def each(&block)
    @id_freqs.each do |id, freq|
      occ = freq_occ[freq]
      e_val = e_value(freq, occ)
      yield(id, freq, e_val) unless e_val > @threshold
    end
  end

  def e_value(freq, occ)
    occ * Math.exp(-1 * lammy * freq)
  end
  
  # lambda is a reserved keyword in Ruby
  def lammy 
    @lammy ||= (sum_freq_occ.to_f / sum_freq)
  end
  
  def freq_occ
    @freq_occ ||= OccurrenceSummer.new(:to_i).sum(id_freqs.values).occurrences
  end
  
  def sum_freq_occ
    @sum_freq_occ ||= freq_occ.collect{|freq,occ| freq * occ}.inject{|sum,n| sum + n}
  end
  
  def sum_freq
    @sum_freq ||= freq_occ.keys.inject{|sum,n| sum + n}
  end
  
  
  private
  
  def valid_id_freqs?(id_freqs)
    return false unless id_freqs.is_a? Hash
     
    if not id_freqs.empty?
      return id_freqs[ id_freqs.keys.first ].is_a?(Integer)
    end
    
    true
  end
  

end