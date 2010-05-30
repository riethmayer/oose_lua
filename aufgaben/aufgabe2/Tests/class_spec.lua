require("loader")
require 'lspec'

LSpec:setup()
----------------------------------------------------------------------------------
-- Testing Class#validate_classname
----------------------------------------------------------------------------------
it("should not be possible to create a class called Object",
   function()
      success = pcall(Class,{'Object'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to create a class called Class",
   function()
      success = pcall(Class,{'Class'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to create a class called Instance",
   function()
      success = pcall(Class,{'Instance'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to create a class called Boolean",
   function()
      success = pcall(Class,{'Boolean'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to create a class called String",
   function()
      success = pcall(Class,{'String'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to create a class called Number",
   function()
      success = pcall(Class,{'Number'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should add 'MyClass' to the global context",
   function()
      Class{'MyClass', attribute1 = String, attribute2 = MyClass }
      return _G['MyClass'] ~= nil
   end)
----------------------------------------------------------------------------------
it("should be optional to pass a superclass",
   function()
      Class{'WithoutSuperclass'}
      -- the topmost Object should be Object
      return WithoutSuperclass._super == Object
   end)
----------------------------------------------------------------------------------
it("should be ok to have one attribute",
   function()
      Class{'ObjectWithOneAttribute'}
      Class{'WithOneAttribute', attribute1 = ObjectWithOneAttribute}
      o = WithOneAttribute:new()
      cond1 =  o.attribute1 == nil
      o.attribute1 = ObjectWithOneAttribute:new()
      cond2 = o.attribute1._class._classname == 'ObjectWithOneAttribute'
      return cond1 and cond2
   end)
----------------------------------------------------------------------------------
it("should be ok to have two attributes",
   function()
       Class{'WithTwoAttributes', nil,
                    attribute1 = Boolean,
                    attribute2 = Boolean}
       return WithTwoAttributes._class_attributes.attribute1 == Boolean and 
         WithTwoAttributes._class_attributes.attribute2 == Boolean
   end)
----------------------------------------------------------------------------------
it("should be possible to pass a Number as attribute",
   function()
      Class{'WithNumberAttribute', nil, number = Number}
      return WithNumberAttribute._class_attributes.number == Number
   end)
----------------------------------------------------------------------------------
it("should be possible to pass a Boolean as attribute",
   function()
      Class{'WithBooleanAttribute', nil, boolean = Boolean}
      return WithBooleanAttribute._class_attributes.boolean == Boolean
   end)
----------------------------------------------------------------------------------
it("should add MagicClass to global context before attribute assignment",
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
it("should not be possible to override an attribute with different type",
   function()
      Class{'FirstType'}
      Class{'SecondType'}
      Class{'Super', nil, first = FirstType}
      local code = pcall(Class, {'Duper', Super, first = SecondType})
      return code == false
   end)
----------------------------------------------------------------------------------
it("should be possible to override an attribute with same type",
   function()
      Class{'Existing'}
      Class{'SuperExisting', with_existing = Existing}
      local code = pcall(Class, 
                         {'DuperExisting', SuperExisting, with_existing = Existing})
      return code
   end)
----------------------------------------------------------------------------------
it("should be possible to override an attribute with same type and add more",
   function()
      Class{'AA'}
      Class{'BB'}
      Class{'WithAA', first = AA}
      local code = pcall(Class,{'WithBB', WithAA, first = AA, second = BB})
      return code
   end)
----------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------
it("should raise an error if an unsupported attribute type is used",
   function()
      local code = pcall(Class,{"FehlerKlasse", falschesAttribut = unbekannterTyp})
      return code == false
   end)
----------------------------------------------------------------------------------
it("should raise an error if a super class has a cylic dependency ",
   function()
      Class{'A'}
      Class{'B', A}
      local call = pcall(Class,{'A', B})
      return call == false
   end)
----------------------------------------------------------------------------------
it("should raise an error if a super class is not a LOS class",
   function()
      local something = 4
      local code = pcall(Class, {'LOSClassWithInvalidSuperclass', something})
      return code == false
   end)
----------------------------------------------------------------------------------
it("should define the basic string class",
   function()
      Class{"StringHolder", str = String}
      o = StringHolder:new()
      return o.str == ""
   end)
----------------------------------------------------------------------------------
it("should define the basic boolean class",
   function()
      Class{"BoolHolder", bool = Boolean}
      o = BoolHolder:new()
      return o.bool == false
   end)
----------------------------------------------------------------------------------
it("should define the basic number class",
   function()
      Class{"NumHolder", num = Number}
      o = NumHolder:new()
      return o.num == 0
   end)
----------------------------------------------------------------------------------
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
it("should allow super calls",
   function()
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
      return m == true and n == true and o == true
   end)
LSpec:teardown()