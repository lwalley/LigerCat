require 'spec_helper'

describe Feedback do
  describe '#contact' do
    it "should send an email from the desired sender" do
      sender  = 'bub@hub.com'
      message = 'my happy message'
      email   = Feedback.contact(sender, message).deliver
      
      ActionMailer::Base.deliveries.should_not be_empty
      
      
      email.from.should be_include sender
      email.body.encoded.should match message
    end
  end
  
  describe '#update_mesh' do
    
    it "puts the offending PMID and MeSH Descriptor in the email" do
      pmid = 1234
      mesh_term = "Slap a Ham"
      email = Feedback.update_mesh(pmid, mesh_term).deliver
      
      ActionMailer::Base.deliveries.should_not be_empty
      
      email.body.encoded.should match pmid.to_s
      email.body.encoded.should match mesh_term
    end
  end
end
