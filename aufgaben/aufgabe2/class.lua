require 'instance'

--  Usage: Class{'<classname>' [, <superclass>] [, <variable> = <type>]+ }
--    * classname (mandatory):
--      - must not be Object
--      - if classname already exists it will be overwritten
--    * superclass (optional):
--      - must be a valid class, which has been created with Class
--      - defaults to Object 
--    * instance variables (optional)
--      instance variables are key value pairs, with a variable name and a type
--      the variable name may be defined in a superclass. If this is the case
--      the type for the defined variable must be compatible with the superclass's
--      variable type. 
--
--      1. Example: 
--        Class{'Foo', foo = Foo }
--        Class{'Bar', Foo, foo = Bar } should be fine. As Bar derives from Foo.
-- 
--      2. Example:
--        Class{'Foo' }
--        Class{'Bar', foo = Foo }
--        Class{'Baz', Bar, foo = Bar } must return an error, as Foo and Bar have 
--        nothing in common.
----------------------------------------------------------------------------------
function Class(argv)
   local klass = {}
   klass.classname   = validate_classname(argv)
   klass._super      = validate_superclass_or_default_to_object(argv)
   klass._methods    = {}
   klass._attributes = validate_attributes(klass, argv)
   klass.new         = function(self, ...)                          
                          return Instance.new(self, unpack(arg))
                       end
   delegate_to_class_methods(klass)
   delegate_to_superclass_methods(klass)
   publish(klass)
   return klass
end
----------------------------------------------------------------------------------
function validate_classname(argv)
   class_name = argv[1]
   if(class_name and (type(class_name) == "string")) then
      reserved = {"Class", "Object", "Instance", "Boolean", "String", "Number"}
      for i,v in ipairs(reserved) do
         if v == class_name then
            error("This class can't be overridden")
         end
      end
      return class_name
   end
   error("Undefined class name. Usage: Class{'ClassName'}")
end
----------------------------------------------------------------------------------
function validate_superclass_or_default_to_object(argv)
   class_name = argv[2]
   return class_name and class_exists(class_name) or Object
end
----------------------------------------------------------------------------------
-- function Classname:foo() ... end => Classname.methods == { foo = function ... end }
-- requires delegation for newindex, index and call?
function delegate_to_class_methods(klass)
   local meta = {}
   meta.__index    = function(self,key) 
                        return self._methods[key]
                     end
   meta.__newindex = function(self,index,key)
                        self.methods[index] = key
                     end
   setmetatable(klass, meta)
end
----------------------------------------------------------------------------------
function delegate_to_superclass_methods(klass)
   local meta = {} 
   meta.__index = function(self,key) 
                     return self._super[key]
                  end
   setmetatable(klass.methods, meta)
end
----------------------------------------------------------------------------------
function publish(klass)
   _G[klass.classname] = klass
end
----------------------------------------------------------------------------------
function validate_attributes(klass,argv)
   argv[1] = nil -- name is the 1st parameter
   argv[2] = nil -- superclass is the 2nd parameter
   -- other parameters are tables which define some classes
   local result = klass._super.attributes or {} -- a list with defined params
   for param,klassname in pairs(argv) do
      if class_exists(klassname) and not_yet_defined(result,param, klassname) then
         result[param] = klassname
      end
   end
   return result
end
----------------------------------------------------------------------------------
function class_exists(klassname)
   return type(klassname) == "table"
end
----------------------------------------------------------------------------------
function not_yet_defined(given, param, klassname)
   if(given and given.param and given.param == klassname) then
      return false
   else
      return true
   end
end
----------------------------------------------------------------------------------
-- Class{'Classname', foo = <Class> } => Classname._attributes = {foo = <Class>}
-- Checks existence of <Class> and whether foo has been defined in Object already.
-- If foo has been defined in Object already, <Class> must be equal to or deriving from foo._class._super._attributes[foo].
-- Class{'Classname', Superclass, foo = <Class>} must check compatibility for Superclass and its superclass's attributes.
function validate_attributes(klass, argv)
   return setattributes(klass, argv)
end
----------------------------------------------------------------------------------
function is_superclass(instance, klass)
   local instance_class = instance._class
   return klass.is_superclass(instance._class)
end
----------------------------------------------------------------------------------
function type_mismatch(klass1, klass2)
   error("Type mismatch: "..klass1.." is incompatible to "..klass2..".")
end