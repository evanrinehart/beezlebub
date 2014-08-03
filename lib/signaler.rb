class Signaler

  # wrapper for Process.kill 'ALRM' which caches the target pid
  # used to wake up the dispatcher process

  PID_PATH = '/var/tmp/dispatcher.pid'

  def initialize pid_path=PID_PATH
    @pid_path = pid_path
    @pid = nil
  end

  def get_pid # caching property reader
    return @pid if @pid
    return nil if !File.exists?(@pid_path)

    pid = IO.read(@pid_path).to_i
    if pid == 0 || pid == Process.pid # myself
      raise "bad dispatcher pid = #{pid}"
    else
      @pid = pid
      @pid
    end
  end

  def signal
    pid = get_pid
    if pid
      Process.kill 'ALRM', pid
    end
    nil
  end

end
