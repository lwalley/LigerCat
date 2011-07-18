require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'bio'
require 'nokogiri'

describe 'TagCloudProcessor' do
  before(:each) do
    @processor = LigerEngine::ProcessingStrategies::TagCloudProcessor.new
    
    redis_fixture :mesh
  end
  
  describe '#each_pmid' do
    it "should add the MeshKeywords to the OccurrenceSummer and return non-nil if MeshKeywords for that PMID exist" do
      @processor.each_pmid(18445641).should_not be_nil # 18445641 has several mesh keywords in the fixture file
      @processor.occurrence_summer.occurrences.should_not be_empty
    end
    it "should return nil if MeshKeywords for that PMID do not exist" do
      @processor.each_pmid(3029822).should be_nil # 3029810 has no mesh keywords in the fixture file
    end
  end
  
  describe '#each_nonlocal' do
    it "should look up the MeshKeywords for each MEDLINE record and add them to the occurrence summer" do
      @processor.each_nonlocal(medline_record)

      # These are the IDs of the MeSH terms contained in the medline_record
      [368, 369, 5260, 5385, 5918, 6801, 9262, 12983].each do |mesh_keyword_id|
        @processor.occurrence_summer.occurrences[mesh_keyword_id].should == 1
      end
    end
    
    it "should insert them into the local cache database" do
      pmid = medline_record.xpath('./MedlineCitation/PMID').first.text
      
      # Sanity Check
      r = RedisFactory.gimme(:mesh)
      r.delete(pmid)
      r.set_members(pmid).should be_empty, "Sanity Check: PMID #{pmid} should not have any MeshKeywords, but did"
      
      @processor.each_nonlocal(medline_record)
      
      r.set_members(pmid).length.should == 8
    end
    
    it "should not duplicate entries to the occurrence summer" do
      # Here we add two PMIDS which have overlapping MeSH terms. One PMID is cached locally, the other is not.
      local_pmid    = 1285630 # This pmid has MeSH terms in the fixture file.
      nonlocal_pmid = medline_record.xpath('./MedlineCitation/PMID').first.text # Same PMID as in medline_record below
      
      # Sanity Check
      r = RedisFactory.gimme(:mesh)
      r.delete(nonlocal_pmid)
      r.set_members(nonlocal_pmid).should be_empty, "Sanity Check: PMID #{nonlocal_pmid} should not have any MeshKeywords, but did"
              
      @processor.each_pmid(local_pmid)
      @processor.each_nonlocal(medline_record)
      
      @processor.occurrence_summer.occurrences[368].should == 2   # Aged
      @processor.occurrence_summer.occurrences[369].should == 2   # Aged, 80 and Over
      @processor.occurrence_summer.occurrences[5260].should == 2  # Female
      @processor.occurrence_summer.occurrences[6801].should == 2  # Humans
      @processor.occurrence_summer.occurrences[7093].should == 1  # Imidazoles
      @processor.occurrence_summer.occurrences[8297].should == 1  # Male
      @processor.occurrence_summer.occurrences[8875].should == 1  # Middle Aged
      @processor.occurrence_summer.occurrences[5385].should == 1  # Fingers
      @processor.occurrence_summer.occurrences[5918].should == 1  # Glomus Tumor
      @processor.occurrence_summer.occurrences[9262].should == 1  # Nails
      @processor.occurrence_summer.occurrences[12983].should == 1 # Soft Tissue Neoplasms
    end
  end
  
  describe '#return_results' do
    it "should take the occurrence summer, calculate the E-Value, and return the 75 most occurrent" do
      local_pmid    = 1285630 # Cached in local database. See pmids_mesh_keywords fixture
      nonlocal_pmid = medline_record.xpath('./MedlineCitation/PMID').first.text # Same PMID as in medline_record below
            
      @processor.each_pmid(local_pmid)
      @processor.each_nonlocal(medline_record)
      
      results = @processor.return_results
      results.should be_a Array
      results.first.should be_a Hash

      results.first[:mesh_keyword_id].should be_a Fixnum
      results.first[:frequency].should be_a Fixnum
      results.first[:e_value].should be_a Float
    end
  end
end

describe "TagCloudProcessor with Real Data" do
  before(:each) do
    # These are PMIDs from a search for 'Biodiversity Informatics'
    @biodiversity_informatics_pmids = [19783196, 19762632, 19729639, 19593896, 19473217, 19129210, 18784790, 18483570, 18445641, 18335319, 17704120, 17597923, 17594421, 16956323, 16701313, 16680511, 19455221, 19455206, 15253354, 15192219, 15063059, 12376687, 11009408]
    @processor = LigerEngine::ProcessingStrategies::TagCloudProcessor.new
  end
  
  it "should return an array of mesh term ids, maximum of 75" do
    results = @processor.process(@biodiversity_informatics_pmids)
    results.should_not be_empty
    results.length.should <= 75
  end
end



def medline_record
Nokogiri::XML(%(<?xml version="1.0"?>
  <!DOCTYPE PubmedArticleSet PUBLIC "-//NLM//DTD PubMedArticle, 1st January 2009//EN" "http://www.ncbi.nlm.nih.gov/entrez/query/DTD/pubmed_090101.dtd">
  <PubmedArticleSet>
  <PubmedArticle>
      <MedlineCitation Owner="NLM" Status="MEDLINE">
          <PMID>3029822</PMID>
          <DateCreated>
              <Year>1987</Year>
              <Month>04</Month>
              <Day>14</Day>
          </DateCreated>
          <DateCompleted>
              <Year>1987</Year>
              <Month>04</Month>
              <Day>14</Day>
          </DateCompleted>
          <DateRevised>
              <Year>2006</Year>
              <Month>11</Month>
              <Day>15</Day>
          </DateRevised>
          <Article PubModel="Print">
              <Journal>
                  <ISSN IssnType="Print">0035-1040</ISSN>
                  <JournalIssue CitedMedium="Print">
                      <Volume>72</Volume>
                      <Issue>7</Issue>
                      <PubDate>
                          <Year>1986</Year>
                      </PubDate>
                  </JournalIssue>
                  <Title>Revue de chirurgie orthop&#xE9;dique et r&#xE9;paratrice de l'appareil moteur</Title>
              </Journal>
              <ArticleTitle>[Subungual glomus tumor. A case of unusual form]</ArticleTitle>
              <Pagination>
                  <MedlinePgn>509-10</MedlinePgn>
              </Pagination>
              <Abstract>
                  <AbstractText>The authors report a case of glomus tumour developing beneath the nail of the ring finger in a 95 year old woman. In contrast with other similar cases, the pain was moderate and had been present for 20 years. The bony phalanx was deformed. Microscopic examination confirmed the diagnosis of a glomus tumour developing in the soft tissues. The phalanx was amputated.</AbstractText>
              </Abstract>
              <AuthorList CompleteYN="Y">
                  <Author ValidYN="Y">
                      <LastName>Watelet</LastName>
                      <ForeName>F</ForeName>
                      <Initials>F</Initials>
                  </Author>
                  <Author ValidYN="Y">
                      <LastName>Menez</LastName>
                      <ForeName>D</ForeName>
                      <Initials>D</Initials>
                  </Author>
                  <Author ValidYN="Y">
                      <LastName>Pageaut</LastName>
                      <ForeName>G</ForeName>
                      <Initials>G</Initials>
                  </Author>
                  <Author ValidYN="Y">
                      <LastName>Tropet</LastName>
                      <ForeName>Y</ForeName>
                      <Initials>Y</Initials>
                  </Author>
                  <Author ValidYN="Y">
                      <LastName>Vichard</LastName>
                      <ForeName>P</ForeName>
                      <Initials>P</Initials>
                  </Author>
              </AuthorList>
              <Language>fre</Language>
              <PublicationTypeList>
                  <PublicationType>Case Reports</PublicationType>
                  <PublicationType>English Abstract</PublicationType>
                  <PublicationType>Journal Article</PublicationType>
              </PublicationTypeList>
              <VernacularTitle>Tumeur glomique sous ungu&#xE9;ale. Un cas de forme inhabituelle.</VernacularTitle>
          </Article>
          <MedlineJournalInfo>
              <Country>FRANCE</Country>
              <MedlineTA>Rev Chir Orthop Reparatrice Appar Mot</MedlineTA>
              <NlmUniqueID>1272427</NlmUniqueID>
          </MedlineJournalInfo>
          <CitationSubset>IM</CitationSubset>
          <MeshHeadingList>
              <MeshHeading>
                  <DescriptorName MajorTopicYN="N">Aged</DescriptorName>
              </MeshHeading>
              <MeshHeading>
                  <DescriptorName MajorTopicYN="N">Aged, 80 and over</DescriptorName>
              </MeshHeading>
              <MeshHeading>
                  <DescriptorName MajorTopicYN="N">Female</DescriptorName>
              </MeshHeading>
              <MeshHeading>
                  <DescriptorName MajorTopicYN="Y">Fingers</DescriptorName>
              </MeshHeading>
              <MeshHeading>
                  <DescriptorName MajorTopicYN="N">Glomus Tumor</DescriptorName>
                  <QualifierName MajorTopicYN="Y">diagnosis</QualifierName>
              </MeshHeading>
              <MeshHeading>
                  <DescriptorName MajorTopicYN="N">Humans</DescriptorName>
              </MeshHeading>
              <MeshHeading>
                  <DescriptorName MajorTopicYN="Y">Nails</DescriptorName>
              </MeshHeading>
              <MeshHeading>
                  <DescriptorName MajorTopicYN="N">Soft Tissue Neoplasms</DescriptorName>
                  <QualifierName MajorTopicYN="Y">diagnosis</QualifierName>
              </MeshHeading>
          </MeshHeadingList>
      </MedlineCitation>
      <PubmedData>
          <History>
              <PubMedPubDate PubStatus="pubmed">
                  <Year>1986</Year>
                  <Month>1</Month>
                  <Day>1</Day>
              </PubMedPubDate>
              <PubMedPubDate PubStatus="medline">
                  <Year>1986</Year>
                  <Month>1</Month>
                  <Day>1</Day>
                  <Hour>0</Hour>
                  <Minute>1</Minute>
              </PubMedPubDate>
              <PubMedPubDate PubStatus="entrez">
                  <Year>1986</Year>
                  <Month>1</Month>
                  <Day>1</Day>
                  <Hour>0</Hour>
                  <Minute>0</Minute>
              </PubMedPubDate>
          </History>
          <PublicationStatus>ppublish</PublicationStatus>
          <ArticleIdList>
              <ArticleId IdType="pubmed">3029822</ArticleId>
          </ArticleIdList>
      </PubmedData>
  </PubmedArticle>


  </PubmedArticleSet>)).xpath('//PubmedArticleSet/PubmedArticle').first
end