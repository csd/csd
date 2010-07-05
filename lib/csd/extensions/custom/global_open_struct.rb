module CSD
  class GlobalOpenStruct
    
    def self.method_missing(meth, *args, &block)
      if meth.to_s.ends_with?('=')
        class_variable_set("@@#{meth.to_s.chop}".to_sym, *args)
      else
        class_variable_get("@@#{meth}".to_sym)
      end
    end
    
  end
end