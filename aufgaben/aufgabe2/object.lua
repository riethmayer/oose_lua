-- Basic Object behavior which will be default behavior for all classes.
-- Instance methods are those methods, available for an instance of a class,
-- whereas class methods are those, available for each class.
-- Example usage:
--   o = Object:new()  ;; this is a class method
--   o:classname()     ;; this is an instance method
Object = {
   _super = nil,
   _class_methods = {
      classname  = "Object"
   }
}
-- delegate to its class class methods
local class_method_lookup = {
   __index   = Object._class_methods }
setmetatable(Object,class_method_lookup)
-- self is a class name for a given Class, which is to be instantiated
-- provide
function Object:new()
   local object = {
      _class = self,
      _instance_methods =  {
         -- o:classname() is a call, and _class.classname is string value.
         -- that's why you can't simply delegate that one to Object.
         classname = function(instance)
                        return(instance._class.classname)
                     end  }
   }
   -- delegate to instance methods first
   local instance_method_lookup   = {
      __index   = object._instance_methods }
   setmetatable(object,instance_method_lookup)

   -- after method isn't found in instance delegate to class methods
   local class_method_lookup = {
      __index   = object._class._class_methods }
   setmetatable(object._instance_methods,class_method_lookup)

   return object
end
