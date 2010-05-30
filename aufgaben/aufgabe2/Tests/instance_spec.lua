require 'lspec'
require("loader")

LSpec:setup()
----------------------------------------------------------------------------------
-- pseudo classes, as Class is not defined at this point.
Foo = {
   classname = "Foo",
   _super    = Object,
   _class_methods  = {
      foo = function() return "foo" end
   },
   _attributes = {}
}
setmetatable(Foo,{__index = Foo._class_methods})
setmetatable(Foo._class_methods,{__index = Foo._super})
-- Bar inherits from Foo, and has an attribute foo, with type Foo
Bar = {
   classname = "Bar",
   _super    = Foo,
   _class_methods  = {
      bar = function() return "bar" end
   },
   _attributes = { foo = Foo }
}
setmetatable(Bar,{__index = Bar._class_methods})
setmetatable(Bar._class_methods,{__index = Bar._super})
----------------------------------------------------------------------------------
it("should be possible to instantiate an Object through Instance",
   function()
      local success = pcall(Instance.new,Instance,Object)
      return success
   end)
----------------------------------------------------------------------------------
it("should not build inheritance to Object for Object",
   function()
      local o = Instance:new(Object)
      return (nil == o._super)
   end)
----------------------------------------------------------------------------------
it("should be possible to instantiate a class",
   function()
      local success = pcall(Instance.new,Instance,Foo)      
      return success
   end)
----------------------------------------------------------------------------------
it("should set the class to Foo",
   function()
      local o = Instance:new(Foo)
      return o._class == Foo
   end)
----------------------------------------------------------------------------------
it("should set the superclass to Object if there's no superclass given",
   function()
      local o = Instance:new(Foo)
      return o._super == Object
   end)
----------------------------------------------------------------------------------
it("should instantiate an object, so this can access its class methods",
   function()
      local o = Instance:new(Foo)
      return (o.foo() == "foo")
   end)
----------------------------------------------------------------------------------
it("should instantiate an object with superclass",
   function()
      local b = Instance:new(Bar)
      return (b.foo() == "foo")
   end)

----------------------------------------------------------------------------------
LSpec:teardown()