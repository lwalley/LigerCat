require 'spec_helper'

describe Feedback do
  describe '#contact' do
    it "should send an email from the desired sender" do
      sender  = 'bub@hub.com'
      message = 'my happy message'
      email   = Feedback.create_contact(sender, message)
      
      email.from.should be_include sender
      email.should have_text(/#{message}/)
    end
  end
  
  describe '#update_mesh' do
    
    it "puts the offending PMID and MeSH Descriptor in the email" do
      pmid = 1234
      mesh_term = "Slap a Ham"
      email = Feedback.create_update_mesh(pmid, mesh_term)
      
      email.should have_text(/#{pmid}/)
      email.should have_text(/#{mesh_term}/)
    end
  end
end
