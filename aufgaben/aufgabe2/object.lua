require 'basetypes'
require 'self_super_trap'

Object = {}
Object._classname = "Object"
Object._super = nil
Object._class_attributes = {}
----------------------------------------------------------------------------------
local class_method_lookup = {
   __index   = Object._class_attributes,
   __newindex = Object._class_attributes}
setmetatable(Object,class_method_lookup)
----------------------------------------------------------------------------------
function Object:class_get(key)
   return self._class_attributes[key]
      or self._super and self._super[key]
end
----------------------------------------------------------------------------------
function Object:class_set(key, value)
   if type(value) ~= "function" then
      error("You can only define functions")
   end
   self._class_attributes[key] = Function:new(value)
end
----------------------------------------------------------------------------------
function Object:get(key)
   before_call(self)
   found_decl = self._class[key]
   if found_decl then
      return self._attribute_values[key]
	 or found_decl._default_value()
   else
      error("No accessible attribute "..key..".")
   end
end
----------------------------------------------------------------------------------
function Object:set(key, value)
   found_decl = self._class[key]
   if found_decl and found_decl:can_accept(value) then
      self._attribute_values[key] = value
   else
      local value_type = (value and value._class and value._class._classname)
	 or type(value)
      error("No attribute "..key.." which can be assigned a "
	    ..value_type..".")
   end
end
----------------------------------------------------------------------------------
function before_call(inst)
   set_current_super_self(inst)
end
----------------------------------------------------------------------------------
function Object:new()
   local instance = {}
   instance._class = self
   instance._attribute_values = {}
   local instance_lookup = {}
   instance_lookup.__index = Object.get
   instance_lookup.__newindex = Object.set
   setmetatable(instance, instance_lookup)
   return instance
end
----------------------------------------------------------------------------------
function Object:has_ancestor(other_class)
   local iter = self
   while iter and iter ~= other_class do
      iter = iter._super
   end
   return iter ~= nil
end