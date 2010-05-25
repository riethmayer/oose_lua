require 'lspec'
require 'object'
LSpec:setup()
----------------------------------------------------------------------------------
it("should create a new object",
   function()
      o = Object:new()
      return (nil ~= o)
   end)

----------------------------------------------------------------------------------
it("should should have a classname called 'Object'",
   function()
      o = Object:new()      
      return o.classname == "Object"
   end)
----------------------------------------------------------------------------------
it("should have no superclass",
   function()
      o = Object:new()
      return o._super == nil
   end)
LSpec:teardown()