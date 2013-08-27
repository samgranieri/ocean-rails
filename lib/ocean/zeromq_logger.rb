require 'socket'

#
# This class is a drop-in replacement for the standard Rails logger. It is
# used in production only and uses ZeroMQ as an intelligent, high-capacity
# transport. ZeromqLogger implements enough of the Logger interface to allow
# it to override the standard logger.
#
class ZeromqLogger

  attr_accessor :level, :log_tags


  #
  # Obtains the IP of the current process, initialises the @logger object
  # by instantiating a ZeroLog object which then is used to set up the
  # log data sender.
  #
  def initialize
    super
    # Get info about our environment
    @ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.getnameinfo[0] 
    # Set up the logger
    @logger = ZeroLog.new
    @logger.init_log_data_sender "/tmp/sub_push_#{Process.pid}"
  end

  #
  # Utility function which returns true if the current log level is +DEBUG+ or lower.
  #
  def debug?() @level <= 0; end

  #
  # Utility function which returns true if the current log level is +INFO+ or lower.
  #
  def info?()  @level <= 1; end

  #
  # Utility function which returns true if the current log level is +WARN+ or lower.
  #
  def warn?()  @level <= 2; end

  #
  # Utility function which returns true if the current log level is +ERROR+ or lower.
  #
  def error?() @level <= 3; end

  #
  # Utility function which returns true if the current log level is +FATAL+ or lower.
  #
  def fatal?() @level <= 4; end


  #
  # This is the core method to add new log messages to the Rails log. It does nothing
  # if the level of the message is lower than the current log level, or if the message
  # is blank. Otherwise it creates a JSON log message as a hash, with data for the 
  # following keys:
  #
  # +timestamp+: The time in milliseconds since the start of the Unix epoch.
  #
  # +ip+:        The IP of the logging entity.
  #
  # +pid+:       The Process ID of the logging process.
  #
  # +service+:   The name of the service.
  #
  # +level+:     The log level of the message (0=debug, 1=info, 2=warn, etc).
  #
  # +msg+:       The log message itself. 
  #
  def add(level, msg, progname)
    return true if level < @level
    msg = progname if msg.blank?
    return true if msg.blank?       # Don't send
    #puts "Adding #{level} #{msg} #{progname}"
    milliseconds = (Time.now.utc.to_f * 1000).to_i
    data = { timestamp: milliseconds,
             ip:        @ip,
             pid:       Process.pid,
             service:   APP_NAME,
             level:     level,
             msg:       msg.kind_of?(String) ? msg : msg.inspect
           }
    @logger.log data
    true
  end

end
