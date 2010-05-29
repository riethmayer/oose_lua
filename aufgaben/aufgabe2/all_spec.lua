require 'lspec'
require 'class'
LSpec:setup()
----------------------------------------------------------------------------------
-- Object specific tests
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
it("should inherit from itself",
   function()
      return Object:inherits_from(Object) and String:inherits_from(String)
   end)
----------------------------------------------------------------------------------
it("should inherit as a basic type from object",
   function()
      b = Boolean:inherits_from(Object)
      n = Number:inherits_from(Object)
      s = String:inherits_from(Object)
      return b and n and s
   end)
----------------------------------------------------------------------------------
it("should not inherit from base types",
   function()
      return Object:inherits_from(String) == false
   end)
----------------------------------------------------------------------------------
-- base type specific tests
----------------------------------------------------------------------------------
it("should have Object as superclass",
   function()
      return Boolean._super == Object and Number._super == Object and
         String._super == Object
   end)
----------------------------------------------------------------------------------
it("should should delegate its classname through object",
   function()
      return Boolean:classname() == "Boolean"
   end)
----------------------------------------------------------------------------------
it("should have classnames",
   function()
      return Boolean:classname() == "Boolean" and Number:classname() == "Number" and
   String:classname() == "String"
end)
----------------------------------------------------------------------------------
it("should be instantiatable",
   function()
      local b = Boolean:new()
      local s = String:new()
      local n = Number:new()
      return b == false and s == "" and n == 0
   end)
----------------------------------------------------------------------------------
-- class tests
----------------------------------------------------------------------------------
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
      success, message = pcall(Class,{'Number'})
      return success == false and string.find(message,"This class can't")
   end)
----------------------------------------------------------------------------------
it("should add 'MyClass' to the global context",
   function()
      local klass = Class{'MyClass', attribute1 = String, attribute2 = MyClass }
      assert(klass._classname == "MyClass")
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
      return WithOneAttribute._class_attributes.attribute1 == ObjectWithOneAttribute
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
      Class{'MagicClass', automagic = MagicClass }
      return MagicClass._class_attributes.automagic == MagicClass
   end)
----------------------------------------------------------------------------------
it("should add MagicClass even if its the last instance variable",
   function()
      MagicClass = nil
      Class{'MagicClass', id = Number, automagic = MagicClass }
      return MagicClass._class_attributes.automagic == MagicClass
   end)

----------------------------------------------------------------------------------
it("should initialize basic instance variables",
   function()
      Foo = nil
      Class{'Foo', id = Number, flag = Boolean, msg = String}
      f = Foo:new()
      return f.id == 0 and f.msg == "" and f.flag == false
   end)
----------------------------------------------------------------------------------
it("should respond to classname",
   function()
      Foo = nil
      Class{'Foo'}
      return Foo:classname() == "Foo"
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
      Class{'Fahrzeug', marke = String}
      function Fahrzeug:is_japanese()
         return self.marke == 'Kawasaki'
      end
      Class{"Motorrad", Fahrzeug}
      local ka = Motorrad:new()
      ka.marke = 'Kawasaki'
      return ka:is_japanese() == true
   end)
----------------------------------------------------------------------------------
it("should share instance attributes from super classes",
   function()
      Foo = nil
      Class{'Foo', id = Number}
      function Foo:myId()
         return self.id
      end
      f = Foo:new()
      assert(f:myId() == 0)
      Class{'Bar', Foo}
      b = Bar:new()
      return b:myId() == 0
   end)
----------------------------------------------------------------------------------
it("should raise an error if an unsupported attribute type is used",
   function()
      unbekannterTyp = nil
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
      local s = String:new()
      return s == ""
   end)
----------------------------------------------------------------------------------
it("should define the basic boolean class",
   function()
      local b = Boolean:new()
      return b == false
   end)
----------------------------------------------------------------------------------
it("should define the basic number class",
   function()
      local n = Number:new()
      return n == 0
   end)
----------------------------------------------------------------------------------
it("should initialize number with 0",
   function()
      Class{'WithZeroInitialized', number = Number}
      local n = WithZeroInitialized:new()
      return n.number == 0
   end)
----------------------------------------------------------------------------------
it("should initialize String with ''",
   function()
      Class{'WithStringInitialized', string = String}
      local s = WithStringInitialized:new()
      return s.string == ''
   end)
----------------------------------------------------------------------------------
it("should initialize Boolean with false",
   function()
      Class{'WithBooleanInitialized', bool = Boolean}
      local b = WithBooleanInitialized:new()
      return b.bool == false
   end)
----------------------------------------------------------------------------------
it("should initialize a reference with nil",
   function()
      Class{'AAA'}
      Class{'WithReferenceInitialized', ref = AAA}
      local r = WithReferenceInitialized:new()
      return r.ref == nil
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
-- in depth tests for class
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Class declaration
----------------------------------------------------------------------------------
Class{'MySuper',
      name = String,
      text = String,
      id = Number,
      isFlagged = Boolean,
   }
----------------------------------------------------------------------------------
function MySuper:tostring()
   return 'MySuper '..self.name
end
----------------------------------------------------------------------------------
function MySuper:attstostring()
   return 'MySuper '..self.text ..' '..self.id..' '..tostring(self.isFlagged)
end
----------------------------------------------------------------------------------
function MySuper:print(msg)
   return(msg..' MySuper:print in '..self:tostring())
end
----------------------------------------------------------------------------------
function MySuper:printAtts(msg)
   return(msg..' MySuper:print in '..self:attstostring())
end
----------------------------------------------------------------------------------
function MySuper:init(name)
   self.name = name
end
----------------------------------------------------------------------------------
function MySuper:setAttributes(text, id, isFlagged)
   self.text = text
   self.id = id
   self.isFlagged = isFlagged
end
----------------------------------------------------------------------------------
-- Testing class declarations, initialization, attribute assignments
----------------------------------------------------------------------------------
it("should initialize MySuper:new()",
   function()
      s = MySuper:new()
      return s
   end)
----------------------------------------------------------------------------------
it("should print MySuper:print in MySuper s1",
   function()
      s:init('s1')
      return s:print(' 1.3') == " 1.3 MySuper:print in MySuper s1"
   end)
----------------------------------------------------------------------------------
it("should print 1.4 MySuper:print in MySuper s2",
   function()
      s.name = 's2'
      return s:print(' 1.4') == " 1.4 MySuper:print in MySuper s2"
   end)
----------------------------------------------------------------------------------
it("should print 1.5 MySuper:print in MySuper  0 false",
   function()
      return s:printAtts(' 1.5') == " 1.5 MySuper:print in MySuper  0 false"
   end)
----------------------------------------------------------------------------------
it("should print  1.6 MySuper:print in MySuper text 123 true",
   function()
      s.text = 'text'
      s.id = 123
      s.isFlagged = true
      return s:printAtts(' 1.6') == " 1.6 MySuper:print in MySuper text 123 true"
   end)
----------------------------------------------------------------------------------
it("should throw an error for type mismatch string = number",
   function()
      local type_error = function()
                            s.name = 5
                         end
      return pcall(type_error) == false
   end)
----------------------------------------------------------------------------------
it("should throw an error for type mismatch number = string",
   function()
      local type_error = function()
                            s.id = "neueId"
                         end
      return pcall(type_error) == false
   end)
----------------------------------------------------------------------------------
it("should throw an error for type mismatch boolean = string",
   function()
      local type_error = function()
                            s.isFlagged = "ja"
                         end
      return pcall(type_error) == false
   end)
----------------------------------------------------------------------------------
it("should throw an error for unknown field",
   function()
      local type_error = function()
                            s.unknown_field = 42
                         end
      return pcall(type_error) == false
   end)
----------------------------------------------------------------------------------
it("should throw an error for unknown methods",
   function()
      local type_error = function()
                            s:dosomething()
                         end
      return pcall(type_error) == false
   end)
----------------------------------------------------------------------------------
-- Testing basic inheritance from super class
----------------------------------------------------------------------------------
Class{'MyClass', MySuper}
----------------------------------------------------------------------------------
function MyClass:tostring()
   return 'MyClass '..self.name
end
----------------------------------------------------------------------------------
function MyClass:setname(name)
   self.name = name
end
----------------------------------------------------------------------------------
it("should inherit methods and attributes",
   function()
      mc = MyClass:new()
      mc:setname('m1')
      return mc:print(' 2.3') == " 2.3 MySuper:print in MyClass m1"
   end)
----------------------------------------------------------------------------------
it("should assign to inherited attributes",
   function()
      mc.name = 'm2'
      return mc:print(' 2.4') == " 2.4 MySuper:print in MyClass m2"
   end)
----------------------------------------------------------------------------------
-- Testing inheritance over multiple super classes
----------------------------------------------------------------------------------
Class{'MySub', MyClass}
----------------------------------------------------------------------------------
function MySub:init(name)
   self.name = name
end
----------------------------------------------------------------------------------
it("should inherit print from MySuper, tostring from MyClass and use its own name",
   function()
      b = MySub:new()
      b:setname('sub1')
      return b:print(" 2.5") == " 2.5 MySuper:print in MyClass sub1"
   end)
----------------------------------------------------------------------------------
it("should inherit print from MySuper, tostring in MySub",
   function()
      function MySub:tostring()
         return ' MySub '..self.name
      end
      return b:print(' 2.6') == " 2.6 MySuper:print in  MySub sub1"
   end)
----------------------------------------------------------------------------------
it("should be ok to overwrite class attributes with their own class",
   function()
      return pcall(Class,{'MyNamesOK', MySuper, name = String})
   end)
----------------------------------------------------------------------------------
it("should not be ok to overwrite class attributes with foreign classes",
   function()
      return pcall(Class,{'MyNamesDBL', MySuper, name = Number}) == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to declare attributes with unknown classes",
   function()
      return pcall(Class, {'MyTest', att = unknownType}) == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to inherit from unknown classes",
   function()
      return pcall(Class,{'FalscheKlasse', FalscheOberklasse, att1 = String, att2 = Boolean}) == false
   end)
----------------------------------------------------------------------------------
it("should be possible to create assign a created class on the fly",
   function()
      return pcall(Class,{'Foo', id = Number, f = Foo})
   end)
----------------------------------------------------------------------------------
Class{'MyOther',
      mc = MyClass,
      mc2 = MyClass,
      ms = MySuper,
      mo = MyOther,
   }
----------------------------------------------------------------------------------
function MyOther:init(msg)
   return(msg..' init MyOther')
end
----------------------------------------------------------------------------------
function MyOther:print(msg)
   if self.mc then self.mc:print(' ' .. msg) end
   if self.mo then
      if self.mo == self then
         print(' '..msg..' mo = self')
      else
         self.mo:print(' '..msg)
      end
   end
end
----------------------------------------------------------------------------------
-- Testing complex class assignment for instance attributes
----------------------------------------------------------------------------------
it("should be possible to assign class attributes if their type match",
   function()
      local mo = MyOther:new()
      local mco = MyClass:new()
      mco.name = 'mco1'
      function assign_complex_class()
         mo.mc2 = mco
      end
      return pcall(assign_complex_class) and mo.mc2:print(' 3.3') == " 3.3 MySuper:print in MyClass mco1"
   end)
----------------------------------------------------------------------------------
it("should not be possible to assign class attributes if their type don't match",
   function()
      local mo = MyOther:new()
      local mo2 = MyOther:new()
      function assign_false_complex_class()
         mo.mc2 = mo2
      end
      return pcall(assign_false_complex_class) == false
   end)
----------------------------------------------------------------------------------
it("should have type mismatches assigning base types to complex attributes",
   function()
      local mo = MyOther:new()
      function assign_basic_to_complex()
         mo.mo = "hallo"
      end
      return pcall(assign_basic_to_complex) == false
   end)
----------------------------------------------------------------------------------
it("should have type mismatches assigning MyOther = MyClass",
   function()
      local mo = MyOther:new()
      local mc = MyClass:new()
      function assign_myother_to_myclass()
         mo.mo = mc
      end
      return pcall(assign_myother_to_myclass) == false
   end)
----------------------------------------------------------------------------------
it("should have type mismatch assigning MyClass = MySuper",
   function()
      local mo = MyOther:new()
      local ms = MySuper:new()
      function assign_myclass_to_mysuper()
         mo.mc = ms
      end
      return pcall(assign_myclass_to_mysuper) == false
   end)
----------------------------------------------------------------------------------
-- aspect related tests
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- end of testing
----------------------------------------------------------------------------------
LSpec:teardown()