# This is a controller for static pages like the "about" page.
# Not sure if this is the best way to do it, butit's the best I
# could come up with in my current braindead state.

class StaticController < ApplicationController
  layout 'static'
  before_filter :clear_errors_and_recaptcha
  
  # GET or POST /about
  def about
    if request.post?
      send_feedback
    end
  end


  private

  def send_feedback
    @sender = params["email_sender"]
    @errors[:sender] = "Please enter a valid e-mail address." if @sender.blank? || @sender !~ /(.+)@(.+)\.(.{3})/
    @message = params["email_message"]
    @errors[:message] = "Please enter a message to send." if @message.blank?
    if verify_recaptcha() && @errors.blank?     
      Feedback.deliver_contact(@sender, @message)
      return if request.xhr?
      flash[:notice] = "Thank you for your feedback"
      render :action => "about",  :layout => 'static'
      session[:recaptcha_error] = nil
    else
      @errors[:recaptcha] = "Invalid ReCaptcha. Please ensure you enter the text exactly as it appears." if session[:recaptcha_error]
      @errors[:general] = "There was a problem with your submission, please check the fields below" if @errors      
      flash[:error] = @errors
      render :action => "about", :layout => 'static'
    end
  end
  
  def clear_errors_and_recaptcha
    @errors = {} 
    # session[:recaptcha_error] = nil if params["recaptcha_challenge_field"].nil? 
  end
end
