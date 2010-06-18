--[[
Kilian Müller  210473
Jan Riethmayer    310326
Martin Nowak 302066
]]--

--================================================================================
Object = {}
Object._classname = "Object"
Object._super = nil
Object._class_attributes = {}

--================================================================================

function wrong_value_access(name)
   error("No accessible attribute "..name..".")
end

--================================================================================

function wrong_value_assignement(name, found_decl, value)
   local ex_type = found_decl and found_decl._classname
   local stat, value_type = pcall(function() return value._class._classname end)
   if not stat then
      value_type = type(value)
   end
   local msg
   if ex_type then
      msg = "Existing attribute "..name.." of type "..ex_type.." cannot be "
      .."assigned a value of type "..value_type.."."
   else
      msg = "No declared attribute with "..name..". Cannot assign "
      .."a value of type "..value_type.."."
   end
   error(msg)
end

--================================================================================

----------------------------------------------------------------------------------

local class_method_lookup = {
   __index   = Object._class_attributes,
   __newindex = Object._class_attributes}
setmetatable(Object,class_method_lookup)

----------------------------------------------------------------------------------

function Object:get(key)
   before_call(self)
   local found_decl = self._class[key]
   if found_decl then
      local value = self._attribute_values[key]
      local default = found_decl._default_value()
      return value ~= nil and value or default
   else
      wrong_value_access(key)
   end
end

----------------------------------------------------------------------------------

function Object:set(key, value)
   found_decl = self._class[key]
   if found_decl and found_decl:can_accept(value) then
      self._attribute_values[key] = value
   else
      wrong_value_assignement(key, found_decl, value)
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