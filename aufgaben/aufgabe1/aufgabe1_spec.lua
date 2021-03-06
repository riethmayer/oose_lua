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
      local klass = Class{'MyClass', attribute1 = String, attribute2 = MyClass }
      assert(klass.classname == "MyClass")
      return _G['MyClass'] ~= nil
   end)
it("should be optional to pass a superclass",
   function()
      Class{'WithoutSuperclass'}
      -- the topmost Object should be Object
      return WithoutSuperclass._super == Object
   end)
it("should be ok to have one attribute",
   function()
      Class{'ObjectWithOneAttribute'}
      Class{'WithOneAttribute', attribute1 = ObjectWithOneAttribute}
      return WithOneAttribute._attributes.attribute1 == ObjectWithOneAttribute
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
      Class{'FirstType'}
      Class{'SecondType'}
      Class{'Super', nil, first = FirstType}
      local code = pcall(Class, {'Duper', Super, first = SecondType})
      return code == false
   end)
it("should be possible to override an attribute with same type",
   function()
      Class{'Existing'}
      Class{'SuperExisting', nil, with_existing = Existing}
      local code = pcall(Class, 
                         {'DuperExisting', SuperExisting, with_existing = Existing})
      return code
   end)
it("should be possible to override an attribute with same type and add more",
   function()
      Class{'AA'}
      Class{'BB'}
      Class{'WithAA', first = AA}
      local code = pcall(Class,{'WithBB', WithAA, first = AA, second = BB})
      return code
   end)

it("should delegate methods to superclass",
   function()
      Class{'Fahrzeug', marke = String, baujahr = Number}
      assert(Fahrzeug)
      function Fahrzeug:is_japanese(jahr)
         return self.marke == 'Kawasaki'
      end
      Class{"Motorrad", Fahrzeug, ersatzFahrzeug = Motorrad}
      local ka = Motorrad:new()
      ka.marke = 'Kawasaki'
      ka.baujahr = 1999
      return ka:is_japanese() == true
   end)
it("should raise an error if an unsupported attribute type is used",
   function()
      local code = pcall(Class,{"FehlerKlasse", falschesAttribut = unbekannterTyp})
      return code == false
   end)
it("should raise an error if a super class has a cylic dependency ",
   function()
      Class{'A'}
      Class{'B', A}
      local call = pcall(Class,{'A', B})
      return call == false
   end)
it("should raise an error if a super class is not a LOS class",
   function()
      local something = 4
      local code = pcall(Class, {'LOSClassWithInvalidSuperclass', something})
      return code == false
   end)
it("should define the basic string class",
   function()
      local s = String:new()
      return s.classname == "String"
   end)
it("should define the basic boolean class",
   function()
      local b = Boolean:new()
      return b.classname == "Boolean"
   end)
it("should define the basic number class",
   function()
      local n = Number:new()
      return n.classname == "Number"
   end)
it("should initialize number with 0",
   function()
      Class{'WithZeroInitialized', number = Number}
      local n = WithZeroInitialized:new()
      return n.number == 0
   end)
it("should initialize String with ''",
   function()
      Class{'WithStringInitialized', string = String}
      local s = WithStringInitialized:new()
      return s.string == ''
   end)
it("should initialize Boolean with false",
   function()
      Class{'WithBooleanInitialized', bool = Boolean}
      local b = WithBooleanInitialized:new()
      return b.bool == false
   end)
it("should initialize a reference with nil",
   function()
      Class{'AAA'}
      Class{'WithReferenceInitialized', ref = AAA}
      local r = WithReferenceInitialized:new()
      return r.ref == nil
   end)
it("should give attributes a higher priority than methods",
   function()
      Class{'ClassWithMethod'}
      Class{'ClassWithAttribute', ClassWithMethod, action = String}
      local cwa = ClassWithAttribute:new()
      cwa.action = "attribute"
      function ClassWithMethod:action()
         return "method"
      end
      local action_is_string = type(cwa.action == "string")
      function ClassWithAttribute:action()
         return "another method"
      end
      local attribute_has_priority = type(cwa.action == "string")
      return action_is_string and attribute_has_priority
   end)

LSpec:teardown()