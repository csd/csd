# -*- encoding: UTF-8 -*-

# This module extends the original Kernel module. Note that methods cannot be added via the +include+ method in this case.
#
module Kernel #:nodoc:

  # Checks whether the AI was executed with superuser rights (a.k.a. +sudo+). Returns +true+ or +false+.
  #
  def superuser?
    Process.uid == 0
  end
  
end
