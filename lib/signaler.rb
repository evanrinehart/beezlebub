class Signaler

  PID_PATH = '/var/tmp/dispatcher.pid'

  def initialize pid_path=PID_PATH
    @pid_path = pid_path
    @pid = nil
  end

  def get_pid # caching property reader
puts 'trying to get pid'
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
puts "SIGNALLING PROCESS #{pid}"
      Process.kill 'ALRM', pid
    end
    nil
  end

end
