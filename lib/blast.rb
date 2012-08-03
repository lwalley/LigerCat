class Blast
  attr_accessor :program, :database, :expectation_value
  attr_reader   :results
  
  def initialize(options={})
    @program           = options[:program]           || 'blastn'
    @database          = options[:database]          || 'nr'
    @expectation_value = options[:expectation_value] || 1.0
  end

  def search(fasta_data)
    results = execute_command(fasta_data)
    parse_tab(results)
  end

  private 

  def execute_command(fasta_data)
    command = %(#{Rails.root.join('lib', 'blast_bin', @program)} -db #{@database} -evalue #{@expectation_value} -outfmt "7 sgi sacc evalue" -remote)
    Rails.logger.debug command

    Open3.popen3 command do |stdin, stdout, stderr|
      stdin.write fasta_data
      stdin.close
      output = stdout.read
      errors = stderr.read
      
      if !output.blank?
        return output
      elsif !output.blank?
        raise "Received errors from #{@program}: #{errors}"
      end
    end
  end
  
  def parse_tab(results)
    @results = {}
    
    results.each_line do |line|
      next if line[0,1] == '#' # Skip comment lines
      
      sgi, sacc, evalue = line.strip.split("\t")

      gi_number  = sgi.to_i
      acc_number = sacc
      e_value    = evalue.to_f
      
      unless @results.has_key?(gi_number) && @results[gi_number][:e_value] < e_value
        @results[gi_number] = {:gi_number => gi_number, :accession_number => acc_number, :e_value => e_value}
      end
    end
    
    return @results.values
  end
end

class BlastN < Blast
  # For Nucleotide Sequences
  def initialize(options={})
    options = options.merge({:program => 'blastn'})
    super(options)
  end
end

class TBlastN < Blast
  # For Amino Acid Sequences
  def initialize(options={})
    options = options.merge({:program => 'tblastn'})
    super(options)
  end
end