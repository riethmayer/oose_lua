require 'object'
require 'basetypes'
-- instance behavior
-- Instance is no class, it's a helper to create instances for a given class,
-- sets the superclass, class and the proper method lookup for those.
Instance = {}
-- klass is the 'Foo' in Foo:new()
-- params for Foo:new(6) in case we'll allow parameterized instantiation
function Instance.new(klass,params)
   -- forward object instantiation to object itself
   if klass == Object then
      local o = Object:new()
      return o
   end
   -- instance is a member of klass   
   local instance = {
      _class = klass,
      -- hmm _super is available through class
      -- a:super() is required, which should hold an instance of its super class?
      -- _super = klass._super,
      -- foo.id is an instance variable
      -- its located in instance variables:
      _instance_variables = {}
   }
   -- help finding the instance variables
   -- setmetatable(instance, instance._instance_variables)
   -- delegate methods to its superclass
   -- Account:new() => Instance.new(Account)
   -- setmetatable(instance._instance_variables, klass)
   -- klass.__index = klass
   initialize(instance,klass,params)
   return instance
end
----------------------------------------------------------------------------------
-- initialize the superclass with constructor
-- the class has class_attributes: foo = Foo, bar = Bar
-- so our instance needs o.foo = Foo:new() and o.bar = Bar:new()
function initialize(instance, klass, params)
   for name, type in pairs(klass._class_attributes) do
      local o = type:new()
      instance._instance_variables[tostring(name)] = o
   end
end