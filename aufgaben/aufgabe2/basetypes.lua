require 'object'
----------------------------------------------------------------------------------
Boolean = {}
Boolean._super = Object
Boolean._classname = "Boolean"
setmetatable(Boolean, {
                __index = function(self,key)
                             return self._super[key]
                          end
             })
function Boolean:new()
   return false
end
----------------------------------------------------------------------------------
Number = {}
Number._super = Object
Number._classname = "Number"
setmetatable(Number, {
                __index = function(self,key)
                             return self._super[key]
                          end
             })
function Number:new()
   return 0
end
----------------------------------------------------------------------------------
String = {}
String._super = Object
String._classname = "String"
setmetatable(String, {
                __index = function(self,key)
                             return self._super[key]
                          end
             })
function String:new()
   return ""
end
----------------------------------------------------------------------------------
