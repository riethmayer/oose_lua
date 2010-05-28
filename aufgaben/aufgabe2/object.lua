Object = {}
Object._classname = "Object"
Object._super = nil
Object._class_attributes = {}
Object._class_methods = {}

local class_method_lookup = {
   __index   = Object._class_methods,
   __newindex = Object._class_methods}
setmetatable(Object,class_method_lookup)

----------------------------------------------------------------------------------
function Object:new()
   local instance = {}
   instance._class = self
   instance._attribute_values = {}
   local instance_lookup = {}
   instance_lookup.__index = Object.get
   instance_lookup.__newindex = Object.set
   setmetatable(instance, instance_lookup)
   return object
end
----------------------------------------------------------------------------------
function Object:get(key)
   found_decl = class_has_accessible_decl(key)
   if found_attr then
      return self._attribute_values[key]
	 or found_decl._default_value
   else
      error("No accessible attribute "..key..".")
   end
end
----------------------------------------------------------------------------------
function Object:set(key, value)
   found_decl = class_has_accessible_decl(key)
   if found_decl and found_decl:can_accept(value) then
      self._attribute_values[key] = value
   else
      local value_type = value and value._class._classname
	 or type(value)
      error("No attribute "..key.." which can be assigned a "
	    ..value_type..".")
   end
end
----------------------------------------------------------------------------------
function Object:class_has_accessible_decl(key)
   return self._class[key]
end
----------------------------------------------------------------------------------
function Object:has_ancestor(other_class)
   local iter = self
   while iter and iter ~= other_class do
      iter = iter._super
   end
   return iter ~= nil
end