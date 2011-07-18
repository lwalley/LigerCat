class Feedback < ActionMailer::Base
   def contact(sender, message, sent_at = Time.now)
      @subject = 'LigerCat Feedback'
      @recipients = ['hmiller@mbl.edu','agoddard@mbl.edu', 'rschenk@mbl.edu']
      @from = sender
      @sent_on = sent_at
  	  @body["email"] = sender
   	  @body["message"] = message
      @headers = {}
   end
   
end
