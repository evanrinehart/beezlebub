module Alarm

  # Mixin to equip a class with the ability to sleep until
  # a) it gets an alarm signal OR
  # b) its internal alarm goes off at a specified time
  # whichever comes first.

  # In any case it runs the on_alarm method provided by the class
  # and the internal alarm is cleared. Until the on_alarm method
  # finishes, the process will ignore alarm signals.

  # Enter an event loop that never returns.
  # Calls the classes on_alarm method when the alarm signal occurs.
  def run
    @rpipe, @wpipe = IO.pipe

    @alarm_thread = nil
    @alarm_lock = Mutex.new

    Signal.trap 'ALRM' do
      @wpipe.write 'x'
    end

    # run once on boot
    on_alarm

    loop do
      # drain everything from the pipe without blocking FIXME
      result = IO.select [@rpipe], [], [], 0
      if result
        drainage = @rpipe.read_nonblock 4096
        if drainage.length > 0
          # at most one signal during work will be deferred
          on_alarm
        end
      end

      # block until at least one char was written to the pipe
      @rpipe.read 1

      # this is the essential part that interrupts the alarm
      clear_interruptible_alarm_if_necessary

      # execute the callback, event handler
      on_alarm
    end
  end

  # set (or replace) the alarm clock
  def set_interruptible_alarm_for timestamp
    seconds = (timestamp - Time.now) + 1
    @alarm_lock.synchronize do
      @alarm_thread.kill if @alarm_thread
      @alarm_thread = Thread.new do
        sleep seconds
        @alarm_lock.synchronize do
          @wpipe.write 'y'
        end
      end
    end
  end

  def clear_interruptible_alarm_if_necessary
    @alarm_lock.synchronize do
      @alarm_thread.kill if @alarm_thread
      @alarm_thread = nil
    end
  end

end
