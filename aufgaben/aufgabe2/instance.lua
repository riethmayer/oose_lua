require 'object'
require 'basetypes'
-- instance behavior
-- Instance is no class, it's a helper to create instances for a given class,
-- sets the superclass, class and the proper method lookup for those.
Instance = {}
-- klass is the 'Foo' in Foo:new()
-- params for Foo:new(6) in case we'll allow parameterized instantiation
----------------------------------------------------------------------------------
function BaseNew(klass, params)

   if klass == Object then
      local o = Object:new()
      return o
   end

   local new_instance = {
      _class = klass,
      _super = validate_superclass(klass),
      _instance_variables = {}
   }
   -- instance doesn't know how to respond? Then it asks it class.
   local instance_lookup = {
      __index = function(self,key)
                   return self._instance_variables[key]
                    or self._class[key]
                end,
      __newindex = function(self,key, value)
                      validate_type_safe(self,key,value)
                      self._instance_variables[key] = value
                   end
   }                     
   -- delegation
   setmetatable(new_instance, instance_lookup)
   return new_instance
end
----------------------------------------------------------------------------------
function Instance.new(klass,params)
   local new_instance = BaseNew(klass, params)
   initialize(new_instance, klass, params)
   return new_instance
end
----------------------------------------------------------------------------------
-- checks wether the superclass responds to class, otherwise it defaults to object
function validate_superclass(klass)
   if(klass and klass._super and klass._super._class) then
      return klass._super
   else   
      return Object
   end
end
----------------------------------------------------------------------------------
function validate_type_safe(object, key, value)
   return true
end
----------------------------------------------------------------------------------
-- TODO maybe instantiation would be another topic belonging right into this file
-- initialize the superclass with constructor
function initialize(object, klass, params)
   for name, type in pairs(klass._class_attributes) do
      object._instance_variables[name] = type:new()
   end
end