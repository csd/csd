# encoding: utf-8
module CSD
  class GlobalOpenStruct
    
    def self.method_missing(meth, *args, &block)
      if meth.to_s.ends_with?('=')
        class_variable_set("@@#{meth.to_s.chop}".to_sym, *args)
      else
        begin
          class_variable_get("@@#{meth}".to_sym)
        rescue NameError => e
          #UI.debug "The option `#{meth}´ was accessed but not available."   # FIXME: This line causes a recursion error :)
          nil
        end
      end
    end
    
  end
end