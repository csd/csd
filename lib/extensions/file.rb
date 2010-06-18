module FileExtensions
  
  # A shortcut for <tt>File.join(File.dirname(__FILE__), some_path)</tt>.
  # The caller_path parameter is supposed to be <tt>__FILE__</tt>.
  #
  def relative(caller_path, *args)
    File.join(File.dirname(caller_path), *args)
  end
  
end

class File #:nodoc:
  extend FileExtensions
end
