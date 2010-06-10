module CSD
  class Installer
    
    def initialize(options={})
      @options = options[:options]
      @actions = options[:actions]
      
      case @actions.first
        when 'minisip'
          Minisip.new :options => @options
        else
          p "Unknown application: #{@actions.first}"
      end
      
      
      self
    end
    
    
    
    
  end
end