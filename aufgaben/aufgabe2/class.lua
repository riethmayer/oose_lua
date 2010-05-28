require 'basetypes'
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
-- adding not yet known classes to limbo
_G_limbo_element = "unknown"
_G_limbo = {}
setmetatable(_G, { __index = function(self,key)
                                _G_limbo[key] = _G_limbo_element
                                return _G_limbo_element
                             end } )
----------------------------------------------------------------------------------
function Class(argv)
   local klass = {}
   -- checks for reserved words like Class, Object and so on.
   klass._classname  = validate_classname(argv)
   klass._super      = validate_superclass_or_default_to_object(argv)
   publish(klass)
   klass._class_attributes = unpack_class_attributes(klass, argv)
   klass.new         = function(self, params)
                          local instance = klass._super.new(self) -- assigns _class
                          local instance_variables = {}
                          for name, type in pairs(klass._class_attributes) do
                             if(type == klass) then
                                instance_variables[name] = nil
                             else
                                instance_variables[name] = type:new()
                             end
                          end
                          -- first delegate to instance variables
                          local instance_delegation = {
                             __index = function(self, key)
                                          return instance_variables[key]
                                       end
                          }
                          setmetatable(instance, instance_delegation)

                          -- second delegate to class methods
                          local class_delegation = {
                             __index = function(self,key)
                                          return instance._class[key]
                                       end
                          }
                          setmetatable(instance_variables, class_delegation)
                          return instance
                       end
   -- third delegate to superclass
   setmetatable(klass,{__index = function(self,key) return self._super[key] end})
   return klass
end
----------------------------------------------------------------------------------
function validate_superclass_or_default_to_object(argv)
   local class_name = argv[2]
   local result = {}
   if(class_name and class_exists(class_name)) then
      result = class_name
   else
      result = Object
   end
   return result
end
----------------------------------------------------------------------------------
function unpack_class_attributes(klass,argv)
   argv[1] = nil -- name is the 1st parameter
   argv[2] = nil -- superclass is the 2nd parameter
   -- other parameters are tables which define some classes
   local result = {}
   for name, type in pairs(argv) do
      type = replace_limbo_type(type, klass) -- Class{'Foo', f = Foo} => Foo = limbo
      validate_type_exists(type)
      check_if_name_is_type_conform_with_superclass(klass,name,type)
      result[name] = type
   end
   return result
end
----------------------------------------------------------------------------------
function replace_limbo_type(type, klass)
   if(type == _G_limbo_element and _G_limbo[klass._classname]) then
      type = klass
      _G_limbo[klass._classname] = nil
   end
   return type
end
----------------------------------------------------------------------------------
function validate_type_exists(type)
   if(not class_exists(type)) then
      result = "Undefined:"
      _G_limbo["class_name"] = nil
      for undefined in pairs(_G_limbo) do
         result = result.." ".. undefined
      end
      error(result)
   end
end
----------------------------------------------------------------------------------
function class_exists(klassname)
   if type(klassname) == "table" then
      return klassname
   end
end
----------------------------------------------------------------------------------
function check_if_name_is_type_conform_with_superclass(klass,name,type)
   -- What is conform?
   -- 1. name and type can't be nil, don't have to check for that
   -- 2. Class{'Foo', id = Number}
   --    Foo._super is Object
   --    Object.id doesn't exist (we assume this will never happen)
   --    So it's conform
   if(klass._super == Object) then 
      return true 
   end
   -- 3. Class{'Bar', Foo, id = Number}
   --    Bar._super is Foo
   --    Foo.id's type is Number
   --    Bar.id's type is Number
   --    So it's conform
   for super_name, super_type in pairs(klass._super._class_attributes) do
      if( name == super_name ) then -- id == id
         if(type == super_type) then -- Number == Number
            -- this attribute is fine, so continue checking the remaining ones
         else
            -- 1. Bar's id is more fancy than Foo's id
            --    This means, Class{'Foo', id = Number}
            --    Class{'FancyNumber',Number}
            --    Class{'Bar',Foo, id = FancyNumber} should be fine
            --    type == FancyNumber, super_type == Number
            if(type:inherits_from(super_type)) then
               -- yes type is more special then supertype, nothing happens
            else                           
               -- 2. the name is the same, but there is no inheritance
               --    So this must clash!
               type_mismatch(type, super_type)
            end  -- inheritance check
         end -- type and super_type comparison
      end -- class attribute name comparison
   end -- loop for all class attributes
   return true
end
----------------------------------------------------------------------------------
-- Class{'Classname', foo = <Class> } => Classname._attributes = {foo = <Class>}
-- Checks existence of <Class> and whether foo has been defined in Object already.
-- If foo has been defined in Object already, <Class> must be equal to or
-- deriving from foo._class._super._attributes[foo].
-- Class{'Classname', Superclass, foo = <Class>} must check compatibility for
-- Superclass and its superclass's attributes.
----------------------------------------------------------------------------------
function is_superclass(type, klass)
   return type.classname == klass.classname or is_superclass(type._super, klass)
end
----------------------------------------------------------------------------------
function type_mismatch(klass1, klass2)
   error("Type mismatch: "..klass1.." is incompatible to "..klass2..".")
end
----------------------------------------------------------------------------------
function publish(klass)
   _G[klass._classname] = klass
end
----------------------------------------------------------------------------------
function validate_classname(argv)
   local class_name = argv[1]
   if(class_name and (type(class_name) == "string")) then
      reserved = {"Class", "Object", "Boolean", "String", "Number"}
      for i,v in ipairs(reserved) do
         if v == class_name then
            error("This class can't be overridden")
         end
      end
      return class_name
   end
   error("Undefined class name. Usage: Class{'ClassName'}")
end