require 'lspec'
require 'object'
require 'basetypes'
LSpec:setup()
----------------------------------------------------------------------------------
it("should create a new object",
   function()
      local o = Object:new()
      return (nil ~= o)
   end)
----------------------------------------------------------------------------------
it("should have instances with a classname called 'Object'",
   function()
      local o = Object:new()      
      return o:classname() == "Object"
   end)
----------------------------------------------------------------------------------
it("should have no superclass",
   function()
      local o = Object:new()
      return o._super == nil
   end)
----------------------------------------------------------------------------------
it("should delegate method calls to _class_methods",
   function()
      return (Object:classname() == "Object")
   end)
----------------------------------------------------------------------------------
it("should inherit from itself",
   function()
      return Object:inherits_from(Object) and String:inherits_from(String)
   end)
----------------------------------------------------------------------------------
it("should inherit as a basic type from object",
   function()
      b = Boolean:inherits_from(Object)
      n = Number:inherits_from(Object)
      s = String:inherits_from(Object)
      return b and n and s
   end)
----------------------------------------------------------------------------------
it("should not inherit from base types",
   function()
      return Object:inherits_from(String) == false
   end)
----------------------------------------------------------------------------------
LSpec:teardown()