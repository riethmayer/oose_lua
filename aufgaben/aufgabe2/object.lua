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
function Object:get(key)
   before_call(self)
   found_decl = self._class[key]
   if found_decl then
      local value = self._attribute_values[key]
      local default = found_decl._default_value()
      if value == nil then
	 return default -- might also be nil in case of class_ref
      else
	 return value
      end
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