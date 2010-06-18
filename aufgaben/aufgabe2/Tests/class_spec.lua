require("sm_loader")
require 'lspec'

LSpec:setup("Class Tests")
----------------------------------------------------------------------------------
-- Testing Class#validate_classname
----------------------------------------------------------------------------------
TEST("should not be possible to create a class called Object",
   function()
      success = pcall(Class,{'Object'})
      return success == false
   end)
----------------------------------------------------------------------------------
TEST("should not be possible to create a class called Class",
   function()
      success = pcall(Class,{'Class'})
      return success == false
   end)
----------------------------------------------------------------------------------
TEST("should not be possible to create a class called Instance",
   function()
      success = pcall(Class,{'Instance'})
      return success == false
   end)
----------------------------------------------------------------------------------
TEST("should not be possible to create a class called Boolean",
   function()
      success = pcall(Class,{'Boolean'})
      return success == false
   end)
----------------------------------------------------------------------------------
TEST("should not be possible to create a class called String",
   function()
      success = pcall(Class,{'String'})
      return success == false
   end)
----------------------------------------------------------------------------------
TEST("should not be possible to create a class called Number",
   function()
      success = pcall(Class,{'Number'})
      return success == false
   end)
----------------------------------------------------------------------------------
TEST("should add 'MyClass' to the global context",
   function()
      MyClass = nil
      Class{'MyClass', attribute1 = String, attribute2 = MyClass }
      return _G['MyClass'] ~= nil
   end)
----------------------------------------------------------------------------------
TEST("should be optional to pass a superclass",
   function()
      WithoutSuperclass = nil
      Class{'WithoutSuperclass'}
      -- the topmost Object should be Object
      return WithoutSuperclass._super == Object
   end)
----------------------------------------------------------------------------------
TEST("should be ok to have one attribute",
   function()
      WithOneAttribute = nil
      Class{'ObjectWithOneAttribute'}
      Class{'WithOneAttribute', attribute1 = ObjectWithOneAttribute}
      o = WithOneAttribute:new()
      cond1 =  o.attribute1 == nil
      o.attribute1 = ObjectWithOneAttribute:new()
      cond2 = o.attribute1._class._classname == 'ObjectWithOneAttribute'
      return cond1 and cond2
   end)
----------------------------------------------------------------------------------
TEST("should be ok to have two attributes",
   function()
      WithTwoAttributes = nil
      Class{'WithTwoAttributes', nil,
	    attribute1 = Boolean,
	    attribute2 = Boolean}
      return WithTwoAttributes._class_attributes.attribute1 == Boolean and 
         WithTwoAttributes._class_attributes.attribute2 == Boolean
   end)
----------------------------------------------------------------------------------
TEST("should be possible to pass a Number as attribute",
   function()
      Class{'WithNumberAttribute', nil, number = Number}
      return WithNumberAttribute._class_attributes.number == Number
   end)
----------------------------------------------------------------------------------
TEST("should be possible to pass a Boolean as attribute",
   function()
      Class{'WithBooleanAttribute', nil, boolean = Boolean}
      return WithBooleanAttribute._class_attributes.boolean == Boolean
   end)
----------------------------------------------------------------------------------
TEST("should add MagicClass to global context before attribute assignment",
   function()
      MagicClass = nil
      Class{'MagicClass', automagic = MagicClass}
      o = MagicClass:new()
      cond1 = o.automagic == nil
      o.automagic = MagicClass:new()
      cond2 = o.automagic._class._classname == 'MagicClass'
      return cond1 and cond2
   end)
----------------------------------------------------------------------------------
TEST("should not be possible to override an attribute with different type",
   function()
      FirstType = nil
      SecondType = nil
      Super = nil
      Class{'FirstType'}
      Class{'SecondType'}
      Class{'Super', nil, first = FirstType}
      local code = pcall(Class, {'Duper', Super, first = SecondType})
      return code == false
   end)
----------------------------------------------------------------------------------
TEST("should be possible to override an attribute with same type",
   function()
      Existing = nil
      SuperExisting = nil
      DuperExisting = nil
      Class{'Existing'}
      Class{'SuperExisting', with_existing = Existing}
      Class{'DuperExisting', SuperExisting, with_existing = Existing}
      CHECK_EQ(DuperExisting._classname, "DuperExisting", "Class not inst")
      Existing = nil
      SuperExisting = nil
      DuperExisting = nil
   end)
----------------------------------------------------------------------------------
TEST("should be possible to override an attribute with same type and add more",
   function()
      AA = nil
      BB = nil
      WithAA = nil
      WithBB = nil
      
      Class{'AA'}
      Class{'BB'}
      Class{'WithAA', first = AA}
      Class{'WithBB', WithAA, first = AA, second = BB}
   
   end)
----------------------------------------------------------------------------------
TEST("should delegate methods to superclass",
   function()
      Fahrzeug = nil
      Motorrad = nil
      Class{'Fahrzeug', marke = String, baujahr = Number}
      assert(Fahrzeug)
      function Fahrzeug:is_japanese(jahr)
         return self.marke == 'Kawasaki'
      end
      Class{"Motorrad", Fahrzeug, ersatzFahrzeug = Motorrad}
      local ka = Motorrad:new()
      ka.marke = 'Kawasaki'
      ka.baujahr = 1999

      Fahrzeug = nil
      Motorrad = nil
      return ka:is_japanese() == true
   end)
----------------------------------------------------------------------------------
TEST("should raise an error if an unsupported attribute type is used",
   function()
      local code = pcall(Class,{"FehlerKlasse", falschesAttribut = unbekannterTyp})
      return code == false
   end)
----------------------------------------------------------------------------------
TEST("should raise an error if a super class has a cylic dependency ",
   function()      
      A = nil
      B = nil
      Class{'A'}
      Class{'B', A}
      local call = pcall(Class,{'A', B})
      A = nil
      B = nil
      return call == false
   end)
----------------------------------------------------------------------------------
TEST("should raise an error if a super class is not a LOS class",
   function()
      local something = 4
      local code = pcall(Class, {'LOSClassWithInvalidSuperclass', something})
      return code == false
   end)
----------------------------------------------------------------------------------
TEST("should define the basic string class",
   function()
      Class{"StringHolder", str = String}
      o = StringHolder:new()
      return o.str == ""
   end)
----------------------------------------------------------------------------------
TEST("should define the basic boolean class",
   function()
      Class{"BoolHolder", bool = Boolean}
      o = BoolHolder:new()
      return o.bool == false
   end)
----------------------------------------------------------------------------------
TEST("should define the basic number class",
   function()
      Class{"NumHolder", num = Number}
      o = NumHolder:new()
      return o.num == 0
   end)
----------------------------------------------------------------------------------
TEST("should give attributes a higher priority than methods",
   function()
      ClassWithMethod = nil
      ClassWithAttribute = nil

      Class{'ClassWithMethod'}
      Class{'ClassWithAttribute', ClassWithMethod, action = String}
      local cwa = ClassWithAttribute:new()
      cwa.action = "attribute"
      function ClassWithMethod:action()
         return "method"
      end
      local action_is_string = type(cwa.action) == "string"
      function ClassWithAttribute:action()
         return "another method"
      end
      local attribute_has_priority = type(cwa.action) == "string"

      ClassWithMethod = nil
      ClassWithAttribute = nil

      return action_is_string and attribute_has_priority
   end)
----------------------------------------------------------------------------------
TEST("should allow super calls",
   function()
      M = nil N = nil O = nil
      Class{"M"}
      Class{"N", M}
      Class{"O", N}

      local m = false
      local n = false
      local o = false

      function M:call()
	 assert(n == false)
	 m = true
      end
      function N:call()
	 assert(o == false)
	 super:call()
	 n = true
      end
      function O:call()
	 super:call()
	 o = true
      end
      inst = O:new()
      inst:call()

      M = nil N = nil O = nil

      return m == true and n == true and o == true
   end)
LSpec:teardown()