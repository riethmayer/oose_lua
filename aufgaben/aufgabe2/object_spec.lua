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
it("should have instances with a classname called 'Object'",
   function()
      o = Object:new()      
      return o:classname() == "Object"
   end)
----------------------------------------------------------------------------------
it("should have no superclass",
   function()
      o = Object:new()
      return o._super == nil
   end)
----------------------------------------------------------------------------------
it("should have class methods, because it is a class",
   function()
      return (nil ~= Object._class_methods)
   end)
----------------------------------------------------------------------------------
it("should have no instance methods as a pure class",
   function()
      return (nil == Object._instance_methods)
   end)
----------------------------------------------------------------------------------
it("should delegate method calls to _class_methods",
   function()
      return (Object.classname == "Object")
   end)

LSpec:teardown()