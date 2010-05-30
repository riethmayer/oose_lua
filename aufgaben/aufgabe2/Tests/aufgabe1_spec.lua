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
require("loader")

LSpec:setup()

-------------------------------------------------------------------------------
it("should add 'MyClass' to the global context",
   function()
      Class{'MyClass', attribute1 = String, attribute2 = MyClass }
      return _G['MyClass'] ~= nil
   end)

-------------------------------------------------------------------------------
it("instances should be of class",
   function()
      MyClass = nil
      Class{'MyClass', attribute1 = String, attribute2 = MyClass }
      local o = MyClass:new()
      return (o._class == MyClass)
   end)

-------------------------------------------------------------------------------
it("should be optional to pass a superclass",
   function()
      Class{'WithoutSuperclass'}
      return WithoutSuperclass._super == Object
   end)

-------------------------------------------------------------------------------
it("should be ok to have one attribute",
   function()
      Class{'WithOneAttribute', attribute1 = String}
      local o = WithOneAttribute:new()
      return o.attribute1 == ""
   end)
-------------------------------------------------------------------------------
it("should be ok to have two attributes",
   function()
      Class{'WithTwoAttributes',
            attribute1 = Boolean,
            attribute2 = Number}
      local o = WithTwoAttributes:new()
      return o.attribute1 == false and o.attribute2 == 0
   end)

-------------------------------------------------------------------------------
it("should raise an error on wrong type assignement",
   function()
      WithTwoAttributes = nil
      Class{'WithTwoAttributes',
            a1 = Boolean,
            a2 = Number}
      local o = WithTwoAttributes:new()

      local function WrongAssign(obj)
         obj.a1 = "Fails"
      end
      code, err = pcall(WrongAssign, o)

      return o.a2 == 0 and code == false and type(err) == "string"
   end)

-------------------------------------------------------------------------------
it("should add MagicClass to global context before attribute assignment",
   function()
      MagicClass = nil
      Class{'MagicClass', SelfClassRef = MagicClass }
      o = MagicClass:new()
      o.SelfClassRef = MagicClass:new()
      return true
   end)

-------------------------------------------------------------------------------
it("should throw an error on undefined type attribute",
   function()
      MagicClass = nil
      code, err = pcall(Class, {'MagicClass', Undef = NotDefined })
      return code == false
   end)

-------------------------------------------------------------------------------
it("should not be possible to override an attribute with different type",
   function()
      Class{'FirstType'}
      Class{'SecondType'}
      Class{'Super', nil, first = FirstType}
      local code = pcall(Class, {'Duper', Super, first = SecondType})
      return code == false
   end)

-------------------------------------------------------------------------------

it("should be possible to override an attribute with same type",
   function()
      Class{'One', attr = Boolean}
      Class{'Two', One, attr = Boolean}

      o = One:new()
      t = Two:new()
      o.attr = true
      t.attr = false
      success = o.attr == true and t.attr == false
      o = nil
      t = nil
      return success
   end)

-------------------------------------------------------------------------------

it("should be possible to override an attribute with same type",
   function()
      Class{'Existing'}
      Class{'SuperExisting', nil, with_existing = Existing}
      Class{'DuperExisting', SuperExisting, with_existing = Existing}
      o = Existing:new()
      a = DuperExisting:new()
      a.with_existing = o
      success = a.with_existing._class == Existing
      o = nil
      a = nil
      return success
   end)

-------------------------------------------------------------------------------

it("should be possible to override an attribute with same type and add more",
   function()
      Class{'AA'}
      Class{'BB'}
      Class{'WithAA', first = AA}
      local code = pcall(Class,{'WithBB', WithAA, first = AA, second = BB})
      return code
   end)

-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
it("should raise an error if an unsupported attribute type is used",
   function()
      local code = pcall(Class,{"FehlerKlasse", falschesAttribut = unbekannterTyp})
      return code == false
   end)

-------------------------------------------------------------------------------
it("should raise an error if a super class has a cylic dependency ",
   function()
      Class{'A'}
      Class{'B', A}
      local call = pcall(Class,{'A', B})
      return call == false
   end)

-------------------------------------------------------------------------------
it("should accept convertible assignements",
   function()
      A = nil
      B = nil
      Class{'A', ARef = A}
      Class{'B', A}
      AObj = A:new()
      BObj = B:new()
      AObj.ARef = AObj
      AObj.ARef = BObj
      return AObj.ARef == BObj
   end)

-------------------------------------------------------------------------------
it("should raise an error if a super class is not a LOS class",
   function()
      local something = 4
      local code = pcall(Class, {'LOSClassWithInvalidSuperclass', something})
      return code == false
   end)

-------------------------------------------------------------------------------
it("should initialize a reference with nil",
   function()
      Class{'AAA'}
      Class{'WithReferenceInitialized', ref = AAA}
      local r = WithReferenceInitialized:new()
      return r.ref == nil
   end)

-------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------
it("should be possible to delete the value of a class reference",
   function()
      Class{'Refered', attr1 = Number}
      Class{'ClassWithRef', ref = Refered}
      o = ClassWithRef:new()
      o.ref = Refered:new()
      cond1 = o.ref ~= nil and o.ref._class == Refered
	 and o.ref.attr1 == 0
      o.ref.attr1 = 5
      o.ref = nil
      cond2 = o.ref == nil
      return cond1 and cond2
   end)
-------------------------------------------------------------------------------
LSpec:teardown()

-------------------------------------------------------------------------------