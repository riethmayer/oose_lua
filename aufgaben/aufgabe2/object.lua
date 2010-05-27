-- Basic Object behavior which will be default behavior for all classes.
-- Instance methods are those methods, available for an instance of a class,
-- whereas class methods are those, available for each class.
-- Example usage:
--   o = Object:new()  ;; this is a class method
--   o:classname()     ;; this is an instance method

Object = {}
Object._super = nil
Object._classname = "Object"
Object._class = Object
function Object:classname()
   return self._class and self._class._classname
end
----------------------------------------------------------------------------------
function Object:new()
   local object = {_class = self}
   setmetatable(object, self)
   self.__index = self
   return object
end
----------------------------------------------------------------------------------