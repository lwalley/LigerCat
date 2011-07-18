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
    RAILS_DEFAULT_LOGGER.debug("/bin/echo \"#{fasta_data}\" | #{RAILS_ROOT}/lib/blast_bin/blastcl3 -p #{@program} -d #{@database} -e #{@expectation_value} -m 8")
    `/bin/echo "#{fasta_data}" | #{RAILS_ROOT}/lib/blast_bin/blastcl3 -p #{@program} -d #{@database} -e #{@expectation_value} -m 8`
  end
  
  def parse_tab(results)
    @results = {}
    blast_indices = {:subject_id => 1, :e_value => 10}
    id_indices    = {:gi_num => 1, :accession_num => 3}
    
    results.each_line do |line|
      columns = line.split("\t")
      subject_id = columns[blast_indices[:subject_id]]
      e_value    = columns[blast_indices[:e_value]].to_f
      
      subject_cols = subject_id.split('|')
      gi_number  = subject_cols[id_indices[:gi_num]].to_i
      acc_number = subject_cols[id_indices[:accession_num]]
      acc_number = acc_number.split('.').first
      
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