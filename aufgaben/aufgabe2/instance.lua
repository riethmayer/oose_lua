require 'object'

-- instance behavior
-- Instance is no class, it's a helper to create instances for a given class,
-- sets the superclass, class and the proper method lookup for those.
Instance = {}
-- klass is the 'Foo' in Foo:new()
-- params for Foo:new(6) in case we'll allow parameterized instantiation
function Instance:new(klass,params)
   -- allow object instantiation
   if klass == Object then
      local o = Object:new()
      return o
   end
   -- the object with it's class and superclass
   local object = {
      _class = klass,
      _super = validate_superclass(klass,params),
   }
   -- instance doesn't know how to respond? Then it asks it class.
   local class_method_lookup = {
      __index = function(self,key)
                   return object._class[key]
                end
   }
   -- delegation
   setmetatable(object, class_method_lookup)
   -- initialize(object)
   return object
end
----------------------------------------------------------------------------------
-- checks wether the superclass responds to class, otherwise it defaults to object
function validate_superclass(klass,params)
   if(klass._super and klass._super._class) then
      return klass._super
   else   
      return Object
   end
end
----------------------------------------------------------------------------------
-- TODO maybe instantiation would be another topic belonging right into this file
-- initialize the superclass with constructor
function initialize(object)
   if (object.super._class_methods.init) then
      object._super_init = object._super._class_methods.init
   end
end