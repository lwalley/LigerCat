class Feedback < ActionMailer::Base
  default :to => Ligercat::Application.config.secret_stuff['feedback_recipients']
  default :from => Ligercat::Application.config.secret_stuff['no_reply_address']
  
   def contact(sender, message)
     @message = message
     
     mail(:subject => 'LigerCat Feedback',
          :from    => sender )
   end
   
   def update_mesh(term, pmid)
     @term = term
     @pmid = pmid
     
     mail(:subject => 'LigerCat May Need to Update MeSH Terms')
   end
   
   def resque_failure(worker, queue, payload, exception)
     @worker, @queue, @payload, @exception = worker, queue, payload, exception
     
     mail(subject: "[Resque Failure] #{queue}: #{exception}",
          to:      Ligercat::Application.config.secret_stuff['exception_recipients'])
   end
end
