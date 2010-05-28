--================================================================================
Attribute = {}
function Attribute:can_accept(value)
   return type(value) == "table" and value._classname == self._classname
     or type(value) == type(self._default_value())
end
function Attribute:new(declaration)
   assert(type(declaration) == "table")
   if declaration._super == self then
      return declaration
   else
      assert(declaration:has_ancestor(Object))
      return ClassRef:new(declaration)
   end
end
function Attribute:register_attribute(attr)
   setmetatable(attr, { __index = Attribute})
end
--================================================================================
Boolean = {}
Boolean._super = Attribute
Boolean._classname = "Boolean"
Attribute:register_attribute(Boolean)
function Boolean._default_value()
   return false
end

--================================================================================
Number = {}
Number._super = Attribute
Number._classname = "Number"
Attribute:register_attribute(Number)
function Number._default_value()
   return 0
end

--================================================================================
String = {}
String._super = Attribute
String._classname = "String"
Attribute:register_attribute(String)
function String._default_value()
   return ""
end

--================================================================================
Function = {}
Function._super = Attribute
Function._classname = "Function"
Attribute:register_attribute(Function)
function Function:can_accept(value)
   return false
end
function Function:new(func_def)
   local definition = func_def
   local func = {}
   setmetatable(func, {__index = self, __call = 
		       function(t, ...)
			  return definition(...)
		       end})
   function func._default_value()
      return definition
   end
   return func
end

--================================================================================
ClassRef = {}
ClassRef._super = Attribute
ClassRef._classname = "ClassRef"
Attribute:register_attribute(ClassRef)
function ClassRef:can_accept(value)
   if value and value._class then
      return value._class:has_ancestor(self._ref)
   elseif value == nil then
      return true
   else
      return false
   end
end
function ClassRef:new(class)
   local class_ref = {}
   class_ref._ref = class
   setmetatable(class_ref, {__index = self})
   function class_ref._default_value()
      return nil
   end
   return class_ref
end