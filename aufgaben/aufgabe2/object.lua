-- Basic Object behavior which will be default behavior for all classes.
-- Instance methods are those methods, available for an instance of a class,
-- whereas class methods are those, available for each class.
-- Example usage:
--   o = Object:new()  ;; this is a class method
--   o:classname()     ;; this is an instance method

Object = {}
Object._super = nil
Object._classname = "Object"
Object._class_methods = {
   classname = function(self)
                  return self._classname
               end
}
setmetatable(Object, { __index = function(self, key)
                             return Object._class_methods[key]
                          end })
----------------------------------------------------------------------------------
function Object:new()
   local object = {_class = self}
   setmetatable(object,
                { __index = function(self,key)  return self._class[key] end })
   return object
end
----------------------------------------------------------------------------------
function Object:inherits_from(super_type)
   -- 1. Object:inherits_from(Object) should be true
   if(self == super_type) then
      return true
   else
      -- 2. Foo:inherits_from(Object) should be true
      return self._super and self._super:inherits_from(super_type) or false
   end
end
----------------------------------------------------------------------------------