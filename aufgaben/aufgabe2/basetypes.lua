require 'object'

Boolean = {}
Boolean._super = Object
Boolean._class_methods = {}
Boolean.classname = "Boolean"

function Boolean:new()
   return false
end

Number = {}
Number._super = Object
Number._class_methods = {}
Number.classname = "Number"

function Number:new()
   return 0
end

String = {}
String._super = Object
String._class_methods = {}
String.classname = "String"

function String:new()
   return ""
end

