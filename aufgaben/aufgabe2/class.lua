require "instance"

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

function call_chain(...)
   local functions = arg
   return
   function(...)
      for _, func in ipairs(arg) do
	 func(...)
      end
   end
end

----------------------------------------------------------------------------------

function class_hook(global_table, key)
   assert(_G == global_table)
   if key == "Class" then
      recording_global_forward_decls = true
      return class_impl
   end
   if recording_global_forward_decls then
      return key
   end
end

----------------------------------------------------------------------------------

function verify_restricted_new(global_table, key, value)
   assert(_G == global_table)
   local reserved_names =
      {"Class", "Object", "Function", "ClassRef", "Instance",
       "Boolean", "String", "Number"}
   for _, v in pairs(reserved_names) do
      assert(key ~= v)
   end
   rawset(_G, key, value)
end

----------------------------------------------------------------------------------

recording_global_forward_decls = false

----------------------------------------------------------------------------------

function set_global_indexhook()
   old_meta = getmetatable(_G)
   new_meta = old_meta or {}
   local prev_index_func = new_meta.__index
   if prev_index_func then
      new_meta.__index = call_chain(class_hook, prev_index_func)
   else
      new_meta.__index = class_hook
   end
   local prev_newindex_func = new_meta.__newindex
   if prev_newindex_func then
      new_meta.__newindex = call_chain(verify_restricted_new, prev_newindex_func)
   else
      new_meta.__newindex = verify_restricted_new
   end
   setmetatable(_G, new_meta)
end

----------------------------------------------------------------------------------

set_global_indexhook()

--================================================================================

function wrong_type_decl_error(name, decl_type)
   local message = "Member "..(name or "unknown").." declared with incomaptible\
     type: "..type(decl_type)..", only classes allowed."
   error(message)
end

--================================================================================

function wrong_type_assign_error(ex_type, decl_type)
   local message = "Member "..(name or "unknown").." declared with incomaptible\
     tpye: "..type(decl_type)..". Exisiting of type "..ex_type.classname.."."
   error(message)
end

--================================================================================

function wrong_super_class_error(super_class)
   local message = "Wrong super class of type "..type(super_class).." / "
     ..(super_class and super_class.classname or "").."."
   error(message)
end

--================================================================================

function front(t)
   return table.remove(t, 1)
end

--================================================================================

----------------------------------------------------------------------------------

function class_impl(argv)
   recording_global_forward_decls = false

   local klass = {}
   klass._classname = validated_classname(front(argv))
   klass._super = validated_superclass(front(argv), klass) or Object
   klass._class_attributes = validated_attributes(argv,klass)

   delegate_to_class_methods(klass)

   publish(klass)
   function klass:delete()
      _G[self._classname] = nil
   end
   return klass
end

----------------------------------------------------------------------------------

function validated_classname(class_name)
   if not class_name or type(class_name) ~= "string" then
      error("Undefined class name. Usage: Class{'ClassName'}")
   end
   if _G[class_name] then
      error("Class declaration exists, delete first")
   end
   return class_name
end

----------------------------------------------------------------------------------

function validated_superclass(super_class, klass)
   if super_class and (type(super_class) ~= "table" 
		    or not super_class._classname
		    or super_class:has_ancestor(klass)) then
      wrong_super_class_error(super_class)
   end
   return super_class
end

----------------------------------------------------------------------------------

function validated_attributes(argv,klass)
   check_all_attr_are_tables(argv, klass._classname)
   local attributes = get_forward_decls(argv, klass)
   attributes = add_other_decls(attributes, argv, klass)
   return attributes
end

----------------------------------------------------------------------------------

function check_all_attr_are_tables(argv, klass_name)
   for name, decl_type in pairs(argv) do
      if type(decl_type) ~= "table" and decl_type ~= klass_name then
	 wrong_type_decl_error(name, decl_type)
      end
   end
end

----------------------------------------------------------------------------------

function get_forward_decls(argv, klass)
   local attr = {}
   for name, decl_type in pairs(argv) do
      if decl_type == klass._classname then
	 argv[name] = nil
	 attr[name] = ClassRef:new(klass)
      end
   end
   return attr
end

----------------------------------------------------------------------------------

function add_other_decls(attr, argv, klass)
   for name, decl_type in pairs(argv) do
      check_can_be_assigned(klass._super[name], decl_type)
      attr[name] = Attribute:new(decl_type)
   end
   assert(#argv == #attr)
   argv = nil
   return attr
end

----------------------------------------------------------------------------------

function check_can_be_assigned(existing, declared)
   if existing and not declared:has_ancestor(existing._ref) then
      wrong_type_assign_error(existing, declared)
   end
end

----------------------------------------------------------------------------------

function delegate_to_class_methods(klass)
   local meta = {}
   local self = klass
   meta.__index = klass._super.class_get
   meta.__newindex = klass._super.class_set
   setmetatable(klass, meta)
end

----------------------------------------------------------------------------------

function publish(klass)
   _G[klass._classname] = klass
end

--[[
----------------------------------------------------------------------------------
function check_if_name_is_type_conform_with_superclass(klass,name,type)
   if(klass == nil) then
      return true
   end
   for super_name, super_type in pairs(klass._class_attributes) do
      if(super_name == name) then
         if(klass == super_type) then
            return true
         end
         if(not is_superclass(type, super_type)) then
            type_mismatch(type, super_type)
         end
      end
   end
   return true
end
-- Class{'Classname', foo = <Class> } => Classname._attributes = {foo = <Class>}
-- Checks existence of <Class> and whether foo has been defined in Object already.
-- If foo has been defined in Object already, <Class> must be equal to or deriving from foo._class._super._attributes[foo].
-- Class{'Classname', Superclass, foo = <Class>} must check compatibility for Superclass and its superclass's attributes.
----------------------------------------------------------------------------------
function is_superclass(type, klass)
   return type.classname == klass.classname or is_superclass(type._super, klass)
end
----------------------------------------------------------------------------------
function type_mismatch(klass1, klass2)
   error("Type mismatch: "..klass1.." is incompatible to "..klass2..".")
end
]]--
