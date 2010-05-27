require 'lspec'
require 'object'
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
LSpec:teardown()