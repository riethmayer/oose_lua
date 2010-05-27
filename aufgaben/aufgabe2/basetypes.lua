require 'object'
----------------------------------------------------------------------------------
Boolean = {}
Boolean._super = Object

function Boolean:classname()
   return "Boolean"
end

function Boolean:new()
   return false
end
----------------------------------------------------------------------------------
Number = {}
Number._super = Object

function Number:classname()
   return "Number"
end

function Number:new()
   return 0
end
----------------------------------------------------------------------------------
String = {}
String._super = Object

function String:classname()
   return "String"
end

function String:new()
   return ""
end
----------------------------------------------------------------------------------
