class Sequence < ActiveRecord::Base
  belongs_to :blast_query

  DNA_BASES          = %w(G A T C R Y M K S W H B V D N)
  AMINO_BASES        = %w(G A L M F W K Q E S P V I C Y H R N D T)
  UNIQUE_AMINO_BASES = AMINO_BASES - DNA_BASES

  before_create :add_blank_comment_to_fasta_data

  attr_accessible :fasta_data

  class << self
    # If fasta_data includes any bases unique to amino acids, return true
    # otherwise return false
    def amino_acid?(fasta_data)
      not fasta_data.gsub(/^>.+$/, '').upcase[/[#{UNIQUE_AMINO_BASES.join}]/].nil?
    end

    def extract_gi_from_genbank_comment(fasta_data)
      if fasta_data =~ /^\s*>gi\|(\d+)\|/
        $1
      end
    end
  end

  def add_blank_comment_to_fasta_data
    unless fasta_data.blank?
      self.fasta_data.strip!
      self.fasta_data = ">\n#{self.fasta_data}" unless self.fasta_data.starts_with? '>'
    end
  end

  def amino_acid?
    self.class.amino_acid? self.fasta_data
  end
end
