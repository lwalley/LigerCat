class Feedback < ActionMailer::Base
   def contact(sender, message)
     subject    'LigerCat Feedback'
     from       sender
     recipients FEEDBACK_RECIPIENTS
     body       :message => message
   end
   
   def update_mesh(term, pmid)
     subject    'LigerCat May Need to Update MeSH Terms'
     from       'no-reply@ligercat.org'
     recipients FEEDBACK_RECIPIENTS
     body       :term => term,
                :pmid => pmid
   end
end
