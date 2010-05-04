--[[
Create a object oriented programming language with Lua
this language will be called LOS (Lua Object Sprache)

Objects will save their inner state only, their methods should be
defined within their class.

Classes will be constructed like this:
Class will be a keyword in LOS
Class{'MyClass', SuperClass,
      attribute1 = String,
      attribute2 = MyClass
   }
--]]

require 'lspec'
-- TODO create LOS.lua and add the Class definition
-- require 'LOS'
require 'class'
LSpec:setup()

-- The following tests reflect the requirements for aufgabe1.

it("should add 'MyClass' to the global context",
   function()
      klass = Class{'MyClass',Whateva,
                    attribute1 = String,
                    attribute2 = MyClass }
      return _G['MyClass'] ~= nil
   end)
it("should return nil for to_class(Undefined)",
   function()
      return to_class(Undefined) == nil
   end)
it("should return class if class is defined",
   function()
      Class{'String'}
      return to_class("String") == String
   end)
it("should be optional to pass a superclass",
   function()
      Class{'WithoutSuperclass'}
      -- the topmost Object should be Object? or Nil?
      return WithoutSuperclass._super == nil
   end)
it("should be a valid attribute for empty attribute definitions in classes",
   function()
      return is_valid_attribute({}, 'attr1', 'String')
   end)
it("should not be valid to have the same attribute name with different types",
   function()
      local t = {attr1 = "Boolean"}
      return is_valid_attribute(t, 'attr1', 'String') == false
   end)
it("should not be a valid class if it hasn't been constructed with Class already",
   function()
      return (is_valid_class("Car") == false) and (is_valid_class(Car) == false)
   end)
it("should be a valid class if it has been constructed with Class already",
   function()
      Class{'Car'}
      return is_valid_class("Car") and is_valid_class(Car)
   end)
it("should not be a valid class if it is something weird",
   function()
      code = pcall(to_class,2)
      return code == false
   end)
it("should be ok to have one attribute",
   function()
      Class{'String'}
      Class{'WithOneAttribute', attribute1 = String}
      return WithOneAttribute.attribute1 == String
   end)
it("should be ok to have two attributes",
   function()
       Class{'WithTwoAttributes', nil,
                    attribute1 = Boolean,
                    attribute2 = Boolean}
      return WithTwoAttributes.attribute1 == Boolean and 
         WithTwoAttributes.attribute2 == Boolean
   end)
it("should be possible to pass a Number as attribute",
   function()
      Class{'WithNumberAttribute', nil, number = Number}
      return WithNumberAttribute.number == Number
   end)
it("should be possible to pass a Boolean as attribute",
   function()
      Class{'WithBooleanAttribute', nil, boolean = Boolean}
      return WithBooleanAttribute.boolean == Boolean
   end)
it("should add MagicClass to global context before attribute assignment",
   function()
      MagicClass = nil
      Class{'MagicClass', automagic = MagicClass }
      return MagicClass.automagic == MagicClass
   end)
it("should not be possible to override an attribute with different type",
   function()
      Class{'Super', nil, stringy = String}
      Class{'Duper', Super, stringy = Number}
      -- TODO this should have a try catch block
      -- return true if catched, false otherwise
      return false
   end)
it("should be possible to override an attribute with same type",
   function()
      Class{'Super', nil,   stringy = String}
      Class{'Duper', Super, stringy = String}
      return true
   end)
it("should delegate methods to superclass",
   function()
      Class{'Fahrzeug', marke = String, baujahr = Number}
      assert(Fahrzeug)
      function Fahrzeug:schrottreif(jahr)
         return (self.baujahr + 10) > jahr
      end
      Class{"Motorrad", Fahrzeug, ersatzFahrzeug = Motorrad}
      ka = Motorrad:new()
      assert(ka._super == Fahrzeug)
      ka.marke = 'Kawasaki'
      ka.baujahr = 1999
      return ka:schrottreif(2020) == true
   end)


LSpec:teardown()