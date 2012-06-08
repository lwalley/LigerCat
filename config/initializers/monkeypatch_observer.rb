# In Ruby 1.8.7, Observable will only call the :update function on an observer.
# The problem is, we want to use the observable module in conjunction with some
# ActiveRecord objects, and AR already uses a function called update.
#
# Ruby 1.9 allows an observer to specify which function it would like the observable
# to call, so we monkeypatch the 1.9 code below

module Observable
  
  def add_observer(observer, func=:update)
    @observer_peers = {} unless defined? @observer_peers
    unless observer.respond_to? func
      raise NoMethodError, "observer does not respond to `#{func.to_s}'"
    end
    @observer_peers[observer] = func
  end
  
  def notify_observers(*arg)
    if defined? @observer_state and @observer_state
      if defined? @observer_peers
        @observer_peers.each do |k, v|
          k.send v, *arg
        end
      end
      @observer_state = false
    end
  end
  
end