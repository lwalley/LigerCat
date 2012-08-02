class Feedback < ActionMailer::Base
  default :recipients => Ligercat::Application.config.secret_stuff['feedback_recipients']
  
  
   def contact(sender, message)
     @message = message
     
     mail(:subject => 'LigerCat Feedback',
          :from    => sender )
   end
   
   def update_mesh(term, pmid)
     @term = term
     @pmid = pmid
     
     mail(:subject => 'LigerCat May Need to Update MeSH Terms',
          :from    => Ligercat::Application.config.secret_stuff['no_reply_address'])
   end
end
