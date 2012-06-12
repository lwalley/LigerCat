module LigerEngine
  class Strategy
    include Observable
    
    def log(msg)
      changed
      notify_observers(:log, msg, self.class.name)
    end
  end
end