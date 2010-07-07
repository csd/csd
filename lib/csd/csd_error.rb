module CSD
  
    class CSDError < StandardError
      def self.status_code(code = nil)
        return @code unless code
        @code = code
      end

      def status_code
        self.class.status_code
      end
    end
    
    #class OptionsPathNotFound < CSDError; status_code(200); end

end