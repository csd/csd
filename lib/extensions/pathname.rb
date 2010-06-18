module PathnameExtensions
  
  def enquote
    to_s.enquote
  end
  
end

class Pathname #:nodoc:
  include PathnameExtensions
end
