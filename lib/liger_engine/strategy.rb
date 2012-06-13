module LigerEngine
  class Strategy
    include Observable
    
    # This essentially catches a notification, and forwards it on to any observers of this class
    # allowing notifications to be "bubbled up" from composite strategies.
    def forward_notification(*args)
      changed
      notify_observers *args
    end
    
    # Utility method for logging events inside Strategy classes.
    def log(msg)
      changed
      notify_observers(:log, msg, self.class.name)
    end
  end
end