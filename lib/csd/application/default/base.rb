# -*- encoding: UTF-8 -*-
require 'tmpdir'

module CSD
  # This namespace holds all individual application Modules
  #
  module Application
    # This is the root class of all Applications
    #
    class Base
      
      def initialize
        define_working_directory
      end
      
      # This method chooses the working directory, which will contain downloads needed for various tasks, etc.
      # Note that this directory is *not* removed by the AI in any case. The user has to make sure she knows the
      # location of it (especially if it is a temporary directory which is physically created right here).
      #
      def define_working_directory
        if Options.work_dir
          # The user specified the working directory manually
          path = Options.work_dir
        elsif Options.temp
          # The user specified the working directory to be a system's temporary directory
          # Note that only with this option, the directory is actually created at this point
          path = Dir.mktmpdir 
        else
          # Other than that, we create a subdirectory in the current directory and use that
          app_name = Applications.current ? Applications.current.name : 'application'
          path = File.join(Dir.pwd, "#{app_name}.ai")
        end
        Path.work = path.pathnamify.expand_path
      end
      
    end
  end
end



